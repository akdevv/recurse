import type { IconType } from "react-icons";
import {
  LuBird,
  LuClover,
  LuCoffee,
  LuCoins,
  LuCompass,
  LuHash,
  LuLayers,
  LuLeaf,
  LuMousePointer2,
  LuNotebookPen,
  LuRabbit,
  LuTreeDeciduous,
} from "react-icons/lu";
import type { ChestReward } from "@shared/types.ts";

export const COLLECTIBLE_ICON: Record<string, IconType> = {
  "golden-pointer": LuMousePointer2,
  "rubber-duck": LuBird,
  "lucky-pivot": LuClover,
  "bottomless-stack": LuLayers,
  "perfect-hash": LuHash,
  "big-o-mug": LuCoffee,
  "memo-pad": LuNotebookPen,
  "dijkstra-compass": LuCompass,
  "balanced-bonsai": LuTreeDeciduous,
  "xor-coin": LuCoins,
  "trie-leaf": LuLeaf,
  "tortoise-hare": LuRabbit,
};

export function rewardText(r: ChestReward) {
  if (r.kind === "xp") return { title: `+${r.amount} XP`, sub: "Bonus XP" };
  if (r.kind === "freeze")
    return {
      title: "Streak freeze",
      sub: "Covers one missed day in a week (you can bank 2)",
    };
  return { title: r.name, sub: r.desc };
}
