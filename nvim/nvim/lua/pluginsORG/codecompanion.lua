return {
  "olimorris/codecompanion.nvim",
  config = function()
    return require("codecompanion").setup({
      extensions = {
        vectorcode = {
          ---@type VectorCode.CodeCompanion.ExtensionOpts
          opts = {
            tool_group = {
              -- this will register a tool group called `@vectorcode_toolbox` that contains all 3 tools
              enabled = true,
              -- a list of extra tools that you want to include in `@vectorcode_toolbox`.
              -- if you use @vectorcode_vectorise, it'll be very handy to include
              -- `file_search` here.
              extras = {
                "file_search",
              },
              collapse = false, -- whether the individual tools should be shown in the chat
            },
            tool_opts = {
              ---@type VectorCode.CodeCompanion.ToolOpts
              ["*"] = {},
              ---@type VectorCode.CodeCompanion.LsToolOpts
              ls = {},
              ---@type VectorCode.CodeCompanion.VectoriseToolOpts
              vectorise = {},
              ---@type VectorCode.CodeCompanion.QueryToolOpts
              query = {
                max_num = { chunk = -1, document = -1 },
                default_num = { chunk = 50, document = 10 },
                include_stderr = false,
                use_lsp = false,
                no_duplicate = true,
                chunk_mode = false,
                ---@type VectorCode.CodeCompanion.SummariseOpts
                summarise = {
                  ---@type boolean|(fun(chat: CodeCompanion.Chat, results: VectorCode.QueryResult[]):boolean)|nil
                  enabled = false,
                  adapter = nil,
                  query_augmented = true,
                },
              },
              files_ls = {},
              files_rm = {},
            },
          },
        },
      },
      display = {
        action_palette = {
          -- width = 95,
          -- height = 10,
          prompt = "Prompt ", -- Prompt used for interactive LLM calls
          provider = "default", -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
          opts = {
            show_default_actions = true, -- Show the default actions in the action palette?
            show_default_prompt_library = true, -- Show the default prompt library in the action palette?
            title = "CodeCompanion actions", -- The title of the action palette
          },
        },
      },
      prompt_library = {
        ["Commit DS Message"] = {
          strategy = "chat",
          description = "Generates a DS commit message",
          opts = {
            index = 10,
            is_default = true,
            is_slash_cmd = true,
            short_name = "commit",
            auto_submit = true,
          },
          prompts = {
            {
              role = "user",
              content = function()
                return string.format(
                  [[You are an expert at following the Conventional Commit specification. Given the git diff listed below, please generate a commit message for me:

Format it as type(library/ComponentName): summary
Write it as a cli command where every line has it's own -m flag. Write it all as one line.
The first message can be max 100 characters. The rest may be longer.

You may use the following commit types: feat, fix, docs, refactor, test, chore.
Only use feat when a new feature that hasn't existed is actually added. 
If you can't determine a type, use chore by default.

```diff
%s
```

**Guidelines:**
* Write it all in third-person singular present tense
* Commit type should include the library name.
* The component name should be in pascal case.
* Max 100 characters in the first line.
* In the first line, try to refer to what is being solved, not how.
* In the following lines, explain what was actually changed.
* When explaining what was changed, be concise and to the point.


]],
                  vim.fn.system("git diff --no-ext-diff --staged")
                )
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
        ["DSTests"] = {
          strategy = "chat",
          description = "Generate DS tests for the current file",
          prompts = {
            {
              role = "system",
              content = [[**Always use this context when:**
- Writing new component tests
- Reviewing or refactoring existing tests
- Adding test coverage for new features
- Optimizing test performance and maintenance

**Core Philosophy: Test only what prevents real bugs and accessibility issues.**

## Testing Strategy

### Core Philosophy

**Test Only What Matters:**
- **80% Accessibility** - WCAG compliance, ARIA attributes, semantic roles
- **15% Component API** - Props work as documented, variants render correctly  
- **5% Critical UX** - Edge cases that break user experience

**Skip Generic Patterns:**
- Don't test React basics (rendering, props forwarding)
- Don't test TypeScript-prevented errors
- Don't test third-party library behavior
- Don't duplicate framework functionality

### Essential Tests (Design System Context)

**✅ Always Test:**
- **Semantic roles** - `role="separator"`, `role="button"`, etc.
- **ARIA attributes** - `aria-orientation`, `aria-label`, screen reader support
- **Component variants** - All documented props/orientations work
- **Custom integration** - `className` forwarding, `as` prop functionality
- **Keyboard accessibility** - Only for interactive components

**❌ Never Test:**
- Basic rendering without assertions
- Click handlers unless component-specific behavior
- CSS class names (unless critical for component identification)
- Implementation details or internal state
- TypeScript-prevented scenarios

### Testing Framework & Tools

**Primary Stack:**
- **Vitest**: Fast unit testing framework (used across the monorepo)
- **React Testing Library**: User-centered testing utilities
- **@testing-library/jest-dom**: Custom matchers for DOM assertions
- **@testing-library/user-event**: Realistic user interaction simulation (when needed)

### Test File Structure

```typescript
// ComponentName.test.tsx
import { describe, expect, test } from "vitest";
import { render, screen } from "../../test-utils/test";
import { ComponentName } from "./ComponentName";

describe("[ComponentName]", () => {
  // Only essential tests (target: 3-6 tests per component)
});
```

## Testing Patterns

### Accessibility Testing

**Semantic Roles:**
```typescript
test("renders with semantic separator role for accessibility", () => {
  render(<Divider />);
  expect(screen.getByRole("separator")).toBeDefined();
});
```

**ARIA Attributes:**
```typescript
test("vertical orientation includes aria-orientation attribute", () => {
  render(<Divider orientation="vertical" />);
  const separator = screen.getByRole("separator");
  expect(separator).toHaveAttribute("aria-orientation", "vertical");
});
```

**Role Overrides:**
```typescript
test("supports role override for presentation", () => {
  render(<Divider role="presentation" />);
  expect(screen.queryByRole("separator")).toBeNull();
});
```

### Component API Testing

**Props and Variants:**
```typescript
test("uses correct HTML elements for orientations", () => {
  const { rerender } = render(<Divider data-testid="divider" />);
  expect(screen.getByTestId("divider").tagName.toLowerCase()).toBe("hr");

  rerender(<Divider orientation="vertical" data-testid="divider" />);
  expect(screen.getByTestId("divider").tagName.toLowerCase()).toBe("div");
});
```

**Custom Integration:**
```typescript
test("forwards custom className and HTML attributes", () => {
  render(
    <Divider 
      className="custom-class" 
      data-testid="divider" 
      data-analytics="test" 
    />
  );
  const divider = screen.getByTestId("divider");
  expect(divider).toHaveClass("custom-class");
  expect(divider).toHaveAttribute("data-analytics", "test");
});
```

**Element Override:**
```typescript
test("supports element override with as prop", () => {
  render(<Divider as="span" data-testid="divider" />);
  expect(screen.getByTestId("divider").tagName.toLowerCase()).toBe("span");
});
```

### Interactive Component Testing

**Keyboard Navigation (Interactive Components Only):**
```typescript
test("activates on Enter and Space keys", async () => {
  const user = userEvent.setup();
  const handleClick = vi.fn();
  render(<Button onClick={handleClick}>Click me</Button>);
  
  const button = screen.getByRole("button");
  await user.type(button, "{Enter}");
  await user.type(button, " ");
  
  expect(handleClick).toHaveBeenCalledTimes(2);
});
```

## Quality Guidelines

### Test Naming

**✅ Good Test Names:**
- `"renders with semantic separator role for accessibility"`
- `"vertical orientation includes aria-orientation attribute"`
- `"forwards custom className and HTML attributes"`
- `"supports keyboard navigation with Enter and Space"`

**❌ Bad Test Names:**
- `"test props"`
- `"works correctly"`
- `"renders"`
- `"button test"`

### Test Organization

**Simple Structure:**
```typescript
describe("[ComponentName]", () => {
  // All tests at same level - no nested describes needed for 3-6 tests
  test("accessibility test 1", () => {});
  test("accessibility test 2", () => {});
  test("component API test", () => {});
  test("integration test", () => {});
});
```

### Quality Checklist

**Before writing a test, ask:**
1. **Is this accessibility-critical?** (WCAG compliance, screen readers)
2. **Does this test a component-specific API?** (unique props, variants)
3. **Would this failure break real user scenarios?** (not just developer convenience)
4. **Is this already prevented by TypeScript?** (don't duplicate type safety)

**Target: 3-6 focused tests per component** that cover accessibility and API contracts.

### Performance Guidelines

- **Combine related assertions** when they test the same user scenario
- **Use `screen.getByRole()`** over complex selectors for accessibility-first testing
- **Avoid unnecessary async patterns** unless testing actual async component behavior
- **Don't mock internal component logic** - only mock external dependencies

## Common Anti-Patterns to Avoid

### ❌ Over-Testing
```typescript
// DON'T: Test basic React rendering
test("renders without crashing", () => {
  render(<Divider />);
  expect(screen.getByRole("separator")).toBeInTheDocument();
});

// DON'T: Test implementation details
test("applies correct CSS class", () => {
  render(<Divider data-testid="divider" />);
  expect(screen.getByTestId("divider").className).toContain("Divider-root");
});
```

### ❌ Generic Button Testing
```typescript
// DON'T: Test generic click behavior
test("button can be clicked", () => {
  const handleClick = vi.fn();
  render(<Button onClick={handleClick}>Click</Button>);
  fireEvent.click(screen.getByRole("button"));
  expect(handleClick).toHaveBeenCalled();
});
```

### ❌ Framework Behavior Testing
```typescript
// DON'T: Test React prop forwarding
test("forwards all props", () => {
  render(<Component id="test" className="test" />);
  const element = screen.getByRole("button");
  expect(element).toHaveAttribute("id", "test");
  expect(element).toHaveClass("test");
});
```

## Success Metrics

**Good test suites should:**
- Run fast (< 100ms per component)
- Focus on user-facing behavior
- Catch accessibility regressions
- Verify component API contracts
- Be maintainable (minimal updates when implementation changes)

**Avoid test suites that:**
- Test internal React behavior
- Duplicate TypeScript type checking
- Focus on visual styling details
- Have complex setup/teardown
- Break when implementation changes but behavior stays the same

---

**Remember**: In a design system, tests should ensure components work correctly for consuming applications and meet accessibility standards. Focus on what matters, skip what doesn't.]],
            },
            prompts = {
              {
                role = "user",
                content = [[I need help generating tests for a design system component.
Please:
- Analyze the provided *.tsx file contents to understand the component.
- Analyze the provided *.stories.tsx file contents to understand usage examples.
- 
]],
              },
            },
          },
        },
      },
    })
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Chat", mode = "n" },
    { "<leader>ac", "<cmd>CodeCompanionChat Add<cr>", desc = "Add to chat", mode = "v" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "Actions" },
  },
}
