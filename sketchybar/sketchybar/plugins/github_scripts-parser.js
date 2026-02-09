const { execSync } = require("child_process");

const cmd = `gh pr list --repo=atgse/design-system --repo=atgse/atgse --author=@me --state open --json number,title,url,mergeable,mergeStateStatus,comments,reviews`;
let prs = JSON.parse(execSync(cmd, { encoding: "utf8" }));

prs = prs.map((pr) => {
  pr.comments = pr.comments?.length ?? 0;
  pr.reviews = pr.reviews?.length ?? 0;
  return pr;
});

// Output as JSON for shell script to parse
console.log(JSON.stringify(prs));
