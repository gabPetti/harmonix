pragma Singleton
import QtQuick

// Subsequence matcher for the launcher. Returns 0 for "no match" and a
// positive score otherwise, rewarding the things people actually type:
// prefixes, runs of adjacent characters, and word initials.
QtObject {
  function score(text, query) {
    if (query === "") return 1;

    const haystack = text.toLowerCase();
    const needle = query.toLowerCase();

    let total = 0;
    let cursor = 0;
    let previous = -2;

    for (const character of needle) {
      const found = haystack.indexOf(character, cursor);
      if (found === -1) return 0;

      total += found === previous + 1 ? 8 : 1;
      if (found === 0 || " -_./:".includes(haystack[found - 1])) total += 6;
      total -= Math.min(4, found - cursor) * 0.5;

      previous = found;
      cursor = found + 1;
    }

    if (haystack.startsWith(needle)) total += 20;
    // Nudge concise names ahead of long ones that merely contain the query.
    total += Math.max(0, 12 - haystack.length * 0.08);

    return Math.max(total, 0.01);
  }

  // Best score across several fields (name, generic name, keywords...).
  function scoreAny(fields, query) {
    let best = 0;
    for (const field of fields) {
      if (!field) continue;
      best = Math.max(best, score(field, query));
    }
    return best;
  }
}
