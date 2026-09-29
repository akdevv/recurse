import { useEffect, useState } from "react";
import { LuBell, LuSend } from "react-icons/lu";
import { post, useApi } from "@/lib/api.ts";
import Button from "@/components/common/button.tsx";

type Status = {
  publicKey: string;
  subscriptions: number;
  nextAt: string | null;
};

const key = (b64: string) => {
  const s = atob(
    (b64 + "=".repeat((4 - (b64.length % 4)) % 4))
      .replace(/-/g, "+")
      .replace(/_/g, "/"),
  );
  return Uint8Array.from(s, (c) => c.charCodeAt(0));
};

/** Push subscription for this browser + test button + when the next nudge is due. */
export default function NotifyControls() {
  const [status, reload] = useApi<Status>("/notify");
  const [sub, setSub] = useState<PushSubscription | null | undefined>();
  const [msg, setMsg] = useState("");
  const supported = "serviceWorker" in navigator && "PushManager" in window;

  useEffect(() => {
    if (supported)
      navigator.serviceWorker.ready
        .then((r) => r.pushManager.getSubscription())
        .then(setSub);
  }, [supported]);

  if (!supported)
    return (
      <p className="text-xs text-muted-foreground">
        This browser can't receive push notifications.
      </p>
    );
  if (!status || sub === undefined) return null;

  const enable = async () => {
    setMsg("");
    try {
      if ((await Notification.requestPermission()) !== "granted")
        throw new Error(
          "Notifications are blocked for this site in the browser.",
        );
      const reg = await navigator.serviceWorker.ready;
      const s = await reg.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: key(status.publicKey),
      });
      await post("/notify/subscribe", s.toJSON());
      setSub(s);
      reload();
    } catch (e: any) {
      setMsg(e.message);
    }
  };
  const disable = async () => {
    if (!sub) return;
    await post("/notify/unsubscribe", { endpoint: sub.endpoint });
    await sub.unsubscribe();
    setSub(null);
    reload();
  };
  const test = () =>
    post("/notify/test").then(() =>
      setMsg("Sent. It should pop up in a moment."),
    );

  return (
    <div className="flex flex-wrap items-center justify-between gap-4">
      <div className="flex min-w-0 flex-col gap-0.5">
        <span className="flex items-center gap-2 text-sm font-medium">
          Push notifications
          <span
            className={`flex items-center gap-1.5 rounded-full px-2 py-0.5 text-[11px] font-normal ${
              sub
                ? "bg-success/10 text-success"
                : "bg-secondary text-muted-foreground"
            }`}
          >
            <span
              className={`size-1.5 rounded-full ${sub ? "bg-success" : "bg-muted-foreground/60"}`}
            />
            {sub ? "On" : "Off"} in this browser
          </span>
        </span>
        <span className="text-xs text-muted-foreground">
          {msg ||
            (status.nextAt
              ? `Next nudge around ${new Date(status.nextAt).toLocaleTimeString("en", { hour: "numeric", minute: "2-digit" })}.`
              : sub
                ? "No more nudges today."
                : "Arrive even when the app is closed, as long as the server runs.")}
        </span>
      </div>
      <div className="flex gap-2">
        {sub ? (
          <>
            <Button size="sm" variant="ghost" onClick={disable}>
              Turn off
            </Button>
            <Button size="sm" variant="secondary" onClick={test}>
              <LuSend className="size-3.5" />
              Send a test
            </Button>
          </>
        ) : (
          <Button size="sm" variant="secondary" onClick={enable}>
            <LuBell className="size-3.5" />
            Enable
          </Button>
        )}
      </div>
    </div>
  );
}
