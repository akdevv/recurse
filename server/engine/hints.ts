export const HINT_UNLOCK_S = [10 * 60, 20 * 60];
export const SOLUTION_UNLOCK_S = 30 * 60;

export function unlocks(activeSeconds: number, hintCount: number) {
  return {
    hintsAvailable: HINT_UNLOCK_S.slice(0, hintCount).filter(
      (s) => activeSeconds >= s,
    ).length,
    nextHintAt:
      HINT_UNLOCK_S.find((s, i) => i < hintCount && activeSeconds < s) ?? null,
    solutionAvailable: activeSeconds >= SOLUTION_UNLOCK_S,
    solutionAt: SOLUTION_UNLOCK_S,
  };
}
