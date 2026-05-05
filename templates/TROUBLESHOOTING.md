# Troubleshooting Guide

Guide for resolving common issues with Claude Code and claude-base agents.

## Table of Contents

- [Agent issues](#agent-issues)
- [Claude Code issues](#claude-code-issues)
- [Performance issues](#performance-issues)
- [Common errors](#common-errors)

---

## Agent issues

### The agent does not start

**Symptom**: `/agent-name` does nothing or returns an error.

**Possible causes**:

1. **File not found**
   ```bash
   # Check that the file exists
   ls .claude/commands/agent-name.md
   ```

2. **Incorrect file syntax**
   ```bash
   # Check that the file is valid Markdown
   # The file must start with "# Agent NAME"
   head -5 .claude/commands/agent-name.md
   ```

3. **.claude folder misplaced**
   ```bash
   # The .claude folder must be at the root of the project
   ls -la .claude/
   ```

**Solution**:
- Check the structure of the `.claude/commands/` folder
- Make sure the file has the `.md` extension
- Verify that the content starts with a `# Agent` heading

---

### The agent does not receive arguments

**Symptom**: Arguments passed to the agent are not taken into account.

**Cause**: The `$ARGUMENTS` placeholder is missing or misplaced.

**Solution**:
```markdown
# Agent MY-AGENT

Agent description.

## Context
$ARGUMENTS    <!-- This placeholder is MANDATORY -->

## Instructions
...
```

---

### The agent produces inconsistent results

**Symptom**: Responses vary too much or do not follow the instructions.

**Possible causes**:

1. **Instructions too vague**
   - Add concrete examples
   - Use checklists

2. **Conflicting instructions**
   - Check that there are no contradictions
   - Clearly prioritize the rules

3. **Insufficient context**
   - Add more context in `$ARGUMENTS`
   - Reference specific files

**Solution**:
```markdown
## Instructions

IMPORTANT: [Critical instruction]

YOU MUST [Mandatory action]

NEVER [Forbidden action]

Think hard about [aspect to consider]
```

---

## Claude Code issues

### Claude Code does not start

**Symptom**: The `claude` command does not work.

**Solutions**:

1. **Check the installation**
   ```bash
   which claude
   claude --version
   ```

2. **Reinstall if necessary**
   ```bash
   npm uninstall -g @anthropic-ai/claude-code
   npm install -g @anthropic-ai/claude-code
   ```

3. **Check permissions**
   ```bash
   # On macOS/Linux
   sudo npm install -g @anthropic-ai/claude-code
   ```

---

### Authentication error

**Symptom**: "Invalid API key" or authentication error.

**Solutions**:

1. **Check the API key**
   ```bash
   echo $ANTHROPIC_API_KEY
   ```

2. **Configure the key**
   ```bash
   export ANTHROPIC_API_KEY="sk-ant-..."
   ```

3. **Add to shell profile**
   ```bash
   # .bashrc or .zshrc
   export ANTHROPIC_API_KEY="sk-ant-..."
   ```

---

### Timeout or interrupted connection

**Symptom**: Requests fail after a certain time.

**Causes**:
- Unstable network connection
- Request too long
- Rate limiting

**Solutions**:

1. **Check the connection**
   ```bash
   ping api.anthropic.com
   ```

2. **Reduce request size**
   - Split complex tasks
   - Use specialized agents

3. **Wait and retry**
   - Rate limits reset after a few minutes

---

## Performance issues

### Slow responses

**Symptom**: Claude takes a long time to respond.

**Solutions**:

1. **Reduce the context**
   - Limit files read simultaneously
   - Use targeted agents

2. **Optimize prompts**
   ```markdown
   <!-- Avoid -->
   Analyze the entire project and give me a complete report...

   <!-- Prefer -->
   Analyze the file src/auth.ts and identify security issues.
   ```

3. **Use the right agent**
   - `/explore` for quick discovery
   - Specialized agents for targeted tasks

---

### High token consumption

**Symptom**: API credits are consumed quickly.

**Solutions**:

1. **Avoid large files**
   ```markdown
   <!-- Avoid -->
   Read all files in the project

   <!-- Prefer -->
   Read src/services/auth.ts
   ```

2. **Use targeted agents**
   - A specialized agent consumes less than a generic one

3. **Pre-filter the context**
   - Specify relevant files
   - Exclude node_modules, dist, etc.

---

## Common errors

### "File not found"

**Cause**: Incorrect file path.

**Solution**:
```bash
# Check the path
ls -la path/to/file

# Use paths relative to the root
./src/file.ts  # ✅
src/file.ts    # ✅
/absolute/path # ⚠️ Avoid if possible
```

---

### "Permission denied"

**Cause**: Insufficient permissions on the file or folder.

**Solution**:
```bash
# Check permissions
ls -la file

# Fix if necessary
chmod 644 file.md
chmod 755 folder/
```

---

### "Invalid markdown"

**Cause**: Incorrect Markdown syntax in the agent.

**Checks**:
```markdown
# ✅ Correct
## Level 2 heading

# ❌ Incorrect
##Heading without space
```

**Things to check**:
- Spaces after `#` in headings
- Closing of code blocks (```)
- Table syntax

---

### "Agent not recognized"

**Cause**: The agent name does not match the file.

**Solution**:
```bash
# The command name is based on the file name
.claude/commands/my-agent.md  →  /my-agent
.claude/commands/MyAgent.md   →  /MyAgent
```

---

## General diagnostics

### Diagnostic checklist

```bash
# 1. Check Claude Code
claude --version

# 2. Check the structure
ls -la .claude/
ls -la .claude/commands/

# 3. Check a specific agent
cat .claude/commands/agent-name.md | head -20

# 4. Check the logs (if available)
cat ~/.claude/logs/latest.log
```

### Full reset

If nothing works:

```bash
# 1. Back up the configuration
cp -r .claude .claude.backup

# 2. Reinstall Claude Code
npm uninstall -g @anthropic-ai/claude-code
npm cache clean --force
npm install -g @anthropic-ai/claude-code

# 3. Restore the configuration
mv .claude.backup .claude
```

---

## Getting help

If the problem persists:

1. **Official documentation**: https://code.claude.com/docs/en/overview
2. **GitHub Issues**: https://github.com/anthropics/claude-code/issues
3. **Community Discord**: [discord link if applicable]

Before reporting a bug, prepare:
- Claude Code version (`claude --version`)
- OS and version
- Full error message
- Steps to reproduce
