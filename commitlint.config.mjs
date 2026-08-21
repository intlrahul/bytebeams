const allowedTypes = [
  "feat",
  "fix",
  "refactor",
  "test",
  "docs",
  "chore",
  "build",
  "ci",
  "perf",
  "style",
];

const allowedScopes = [
  "mobile",
  "server",
  "contracts",
  "tooling",
  "docs",
  "ci",
  "workspace",
];

const vagueSubjects = new Set(["update", "changes", "fix bug", "wip"]);

const localRules = {
  "subject-not-vague": ({ subject }) => {
    const normalizedSubject = subject?.trim().toLowerCase() ?? "";
    const valid = !vagueSubjects.has(normalizedSubject);

    return [
      valid,
      `subject must be specific; disallowed subjects: ${[...vagueSubjects].join(", ")}`,
    ];
  },
  "breaking-change-pair": ({ header, raw }) => {
    const hasBreakingMarker = /^[a-z]+(?:\([^)]+\))?!:/.test(header ?? "");
    const hasBreakingFooter = /^BREAKING CHANGE:\s+\S/m.test(raw ?? "");
    const valid = hasBreakingMarker === hasBreakingFooter;

    return [
      valid,
      "breaking commits must use both type(scope)!: summary and a BREAKING CHANGE: footer",
    ];
  },
};

export default {
  extends: ["@commitlint/config-conventional"],
  plugins: [{ rules: localRules }],
  rules: {
    "type-enum": [2, "always", allowedTypes],
    "type-case": [2, "always", "lower-case"],
    "scope-enum": [2, "always", allowedScopes],
    "scope-case": [2, "always", "lower-case"],
    "subject-empty": [2, "never"],
    "subject-max-length": [2, "always", 71],
    "subject-full-stop": [2, "never", "."],
    "subject-not-vague": [2, "always"],
    "breaking-change-pair": [2, "always"],
  },
};
