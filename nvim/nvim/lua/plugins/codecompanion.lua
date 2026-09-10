local ok_local, local_paths = pcall(require, "local.codecompanion_paths")
local agentskills_paths = (ok_local and local_paths.agentskills_paths) or {}

local function get_git_root()
  local result = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return vim.trim(result)
end

local function build_agentskills_paths()
  local paths = vim.deepcopy(agentskills_paths)
  local git_root = get_git_root()
  if git_root then
    local skills_path = git_root .. "/.github/skills"
    if vim.fn.isdirectory(skills_path) == 1 then
      -- avoid duplicates
      local exists = false
      for _, p in ipairs(paths) do
        if p == skills_path then
          exists = true
          break
        end
      end
      if not exists then
        table.insert(paths, skills_path)
      end
    end
  end
  return paths
end

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "ravitemer/codecompanion-history.nvim",
    "cairijun/codecompanion-agentskills.nvim",
  },
  config = function()
    local models = {
      { label = "GPT-4.1", model = "gpt-4.1" },
      {
        label = "Claude Sonnet 4",
        model = "claude-sonnet-4",
      },
      {
        label = "Claude Sonnet 4.5",
        model = "claude-sonnet-4.5",
      },
      {
        label = "Claude Haiku 4.5",
        model = "claude-haiku-4.5",
      },
      {
        label = "Claude Opus 4.5",
        model = "claude-opus-4.5",
      },
      {
        label = "Claude Opus 4.6",
        model = "claude-opus-4.6",
      },
      {
        label = "Gemini 2.5 Pro",
        model = "gemini-2.5-pro",
      },
      {
        label = "GPT-5.2-Codex",
        model = "gpt-5.2-codex",
      },
      {
        label = "GPT-5.3-Codex",
        model = "gpt-5.3-codex",
      },
      {
        label = "GPT-5",
        model = "gpt-5",
      },
      {
        label = "GPT-5 mini",
        model = "gpt-5-mini",
      },
      {
        label = "GPT-5.1",
        model = "gpt-5.1",
      },
      {
        label = "GPT-5.1-Codex",
        model = "gpt-5.1-codex",
      },
      {
        label = "GPT-5.1-Codex-Max",
        model = "gpt-5.1-codex-max",
      },
      {
        label = "GPT-5.2",
        model = "gpt-5.2",
      },
      {
        label = "Grok Code Fast 1",
        model = "grok-code-fast-1",
      },
    }

    -- local model_actions = {
    --   ["Chat"] = {
    --     strategy = "chat",
    --     desc = "Start chat (default Copilot model)",
    --     adapter = { name = "copilot" },
    --     prompts = {
    --       { role = "user", content = "Start a new chat session.", opts = { auto_submit = false } },
    --     },
    --   },
    -- }
    --
    -- for _, m in ipairs(models) do
    --   model_actions["Chat/" .. m.label] = {
    --     strategy = "chat",
    --     desc = "Start chat with Copilot " .. m.label,
    --     adapter = {
    --       name = "copilot",
    --       model = m.model,
    --     },
    --     prompts = {
    --       { role = "user", content = "Start a new chat session.", opts = { auto_submit = false } },
    --     },
    --   }
    -- end

    local function build_model_picker_items()
      local items = {}

      for _, m in ipairs(models) do
        table.insert(items, {
          name = m.label,
          -- use chat interaction for opening a new chat flow
          interaction = "chat",
          description = "Start chat with Copilot " .. m.label,
          callback = function(context)
            require("codecompanion").chat({
              buffer_context = context,
              adapter = {
                name = "copilot",
                model = m.model,
              },
              messages = {
                {
                  role = "user",
                  content = "Start a new chat session.",
                },
              },
            })
          end,
        })
      end

      return items
    end

    return require("codecompanion").setup({
      -- actions = vim.tbl_extend("force", model_actions),
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
        history = {
          enabled = true,
          opts = {
            -- Keymap to open history from chat buffer (default: gh)
            keymap = "gh",
            -- Keymap to save the current chat manually (when auto_save is disabled)
            save_chat_keymap = "sc",
            -- Save all chats by default (disable to save only manually using 'sc')
            auto_save = true,
            -- Number of days after which chats are automatically deleted (0 to disable)
            expiration_days = 0,
            -- Picker interface (auto resolved to a valid picker)
            picker = "snacks", --- ("telescope", "snacks", "fzf-lua", or "default")
            ---Optional filter function to control which chats are shown when browsing
            chat_filter = nil, -- function(chat_data) return boolean end
            -- Customize picker keymaps (optional)
            picker_keymaps = {
              rename = { n = "r", i = "<M-r>" },
              delete = { n = "d", i = "<M-d>" },
              duplicate = { n = "<C-y>", i = "<C-y>" },
            },
            ---Automatically generate titles for new chats
            auto_generate_title = true,
            title_generation_opts = {
              ---Adapter for generating titles (defaults to current chat adapter)
              adapter = nil, -- "copilot"
              ---Model for generating titles (defaults to current chat model)
              model = nil, -- "gpt-4o"
              ---Number of user prompts after which to refresh the title (0 to disable)
              refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
              ---Maximum number of times to refresh the title (default: 3)
              max_refreshes = 3,
              format_title = function(original_title)
                -- this can be a custom function that applies some custom
                -- formatting to the title.
                return original_title
              end,
            },
            ---On exiting and entering neovim, loads the last chat on opening chat
            continue_last_chat = false,
            ---When chat is cleared with `gx` delete the chat from history
            delete_on_clearing_chat = false,
            ---Directory path to save the chats
            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
            ---Enable detailed logging for history extension
            enable_logging = false,

            -- Summary system
            summary = {
              -- Keymap to generate summary for current chat (default: "gcs")
              create_summary_keymap = "gcs",
              -- Keymap to browse summaries (default: "gbs")
              browse_summaries_keymap = "gbs",

              generation_opts = {
                adapter = nil, -- defaults to current chat adapter
                model = nil, -- defaults to current chat model
                context_size = 90000, -- max tokens that the model supports
                include_references = true, -- include slash command content
                include_tool_outputs = true, -- include tool execution results
                system_prompt = nil, -- custom system prompt (string or function)
                format_summary = nil, -- custom function to format generated summary e.g to remove <think/> tags from summary
              },
            },

            -- Memory system (requires VectorCode CLI)
            memory = {
              -- Automatically index summaries when they are generated
              auto_create_memories_on_summary_generation = true,
              -- Path to the VectorCode executable
              vectorcode_exe = "vectorcode",
              -- Tool configuration
              tool_opts = {
                -- Default number of memories to retrieve
                default_num = 10,
              },
              -- Enable notifications for indexing progress
              notify = true,
              -- Index all existing memories on startup
              -- (requires VectorCode 0.6.12+ for efficient incremental indexing)
              index_on_startup = false,
            },
          },
        },
        -- readme: https://github.com/cairijun/codecompanion-agentskills.nvim
        agentskills = {
          opts = {
            paths = build_agentskills_paths(),
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
      prompt_library = vim.tbl_extend("force", {
        ["Chat with Copilot model ..."] = {
          strategy = "chat",
          description = "Pick a Copilot model, then start chat",
          opts = {
            stop_context_insertion = true,
          },
          picker = {
            prompt = "Select Copilot model",
            columns = { "name", "description" },
            items = build_model_picker_items,
          },
        },
      }, {
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
                  [[You are an expert at following the Conventional Commit specification. Given the git diff listed below, generate a commit message for me:

Format it as type(library/ComponentName): summary
The "ComponentName" is the file name and must be without the file extension.
If a file that is not necessarily a component, like a util or test file, treat it as a filename but omit the last extension.
Example: "hasEntries.test.ts" would become "hasEntries.test".
This format is strictly necessary for our versioning tools to be able to parse our commits.

Write it as a cli command where every line has it's own -m flag. Write it all as one line.
The first message can be max 100 characters and its summary must be lower case. The rest may be longer but still concise, and has no casing requirements.

You can use the following commit types: feat, fix, docs, refactor, test, chore.
Only use feat when a new user-facing feature is added.
Use fix when changing existing functionality that is user-facing.
Use docs when the main purpose of the change is to update documentation.
If you can't determine a type, use chore by default.

The messages must be concise and to the point. Avoid unnecessary words and extra details that can be deciphered from the type, library and file name.
It must be clear and easy to understand at a glance while scanning through commit history.
Common shortened words are encouraged, such as "docs" instead of "documentation" and "md file" instead of "markdown file".
Abbreviations are discouraged, like "cfg" to mean "config", unless they are extremely common, such as "api".

Avoid using words that can be ambigous such as "improves" or "better". Be specific such as "lowers" or "removes".
An example of what I mean is this:
```
# Not like this
chore(components/ListItemOption): updates selector to use :where for lower specificity

# Like this
chore(components/ListItemOption): updates selector to use :where for lower specificity
```

Here are a few other examples of outputs I like:
```
git cm -m "docs(backend/GettingStarted.md): updates Redis installation and usage" -m "Adds link to Redis docs regarding installation"
                  
git cm -m "chore(backend/requireAuth.ts): moves requireAuth helper to a separate util file" -m "Implements user extraction from session cookie and returns 401 response if unauthenticated" -m "Uses validateSession from session.service to verify session token"

git cm -m "fix(horse-shared/CompactGameTypeMenu.tsx): fixes crash caused by stale item id" -m "Migrates menu implementation to newly recommended pattern"

git cm -m "feat(components/Select.tsx): adds hideLabel and disableItemWrap props" -m "Improves accessibility with better labeling and updated roles" -m "Fixes unwanted label truncation when only one item is selected"
```

Do note that you don't NEED to include more lines if the first sufficiently describes the change. Only include more lines if they add important context that isn't already clear from the first line.

```diff
%s
```

**Guidelines:**
* Write it all in third-person singular present tense
* Commit type should include the library name.
* The component name should be in pascal case.
* Max 100 characters in the first line.
* In the first line, try to concisely explain what has changed.
* In the following lines, provide more details regarding how and why if not immediately clear, but keep it concise.


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
      }),
    })
  end,
  keys = {
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Chat", mode = "n" },
    { "<leader>ac", "<cmd>CodeCompanionChat Add<cr>", desc = "Add to chat", mode = "v" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "Actions" },
  },
}
