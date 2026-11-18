const { execSync } = require("child_process");

// Resolved via PATH, which github_scripts.sh exports for launchd/brew services
const GH = "gh";
const REPOS = ["atgse/design-system", "atgse/atgse"];

const prs = REPOS.flatMap((repo) => {
  const cmd = `${GH} pr list --repo=${repo} --author=@me --state open --json number,title,url,mergeable,mergeStateStatus,comments,reviews`;
  const result = JSON.parse(execSync(cmd, { encoding: "utf8" }));

  return result.map((pr) => ({
    ...pr,
    comments: pr.comments?.length ?? 0,
    reviews: pr.reviews?.length ?? 0,
    approved: pr.reviews?.some((r) => r.state === "APPROVED") ?? false,
  }));
});

// Output as JSON for shell script to parse
console.log(JSON.stringify(prs));
