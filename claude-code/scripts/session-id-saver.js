#!/usr/bin/env node
// PostToolUse hook: Auto-save SESSION_ID from Codex/Gemini MCP calls
// Writes to .fantayspec/sessions.md in current working directory
const fs = require('fs');
const path = require('path');

let data = '';
process.stdin.on('data', c => data += c);
process.stdin.on('end', () => {
  try {
    const event = JSON.parse(data);
    const output = event.tool_output?.output || event.tool_result?.output || '';

    // Parse nested JSON from MCP output
    let sessionId = '';
    let model = '';

    const toolName = event.tool_name || '';
    if (toolName.includes('codex')) model = 'CODEX';
    else if (toolName.includes('gemini')) model = 'GEMINI';
    else { console.log(data); return; }

    // Extract SESSION_ID from various response formats
    try {
      const parsed = typeof output === 'string' ? JSON.parse(output) : output;
      sessionId = parsed?.result?.SESSION_ID || parsed?.SESSION_ID || '';
    } catch {
      const match = output.match(/SESSION_ID["\s:]+([0-9a-f-]{36})/i);
      if (match) sessionId = match[1];
    }

    if (!sessionId) { console.log(data); return; }

    // Find .fantayspec/ directory (check cwd and parents)
    let dir = process.cwd();
    let specDir = '';
    for (let i = 0; i < 5; i++) {
      const candidate = path.join(dir, '.fantayspec');
      if (fs.existsSync(candidate)) { specDir = candidate; break; }
      const parent = path.dirname(dir);
      if (parent === dir) break;
      dir = parent;
    }

    if (!specDir) {
      // No .fantayspec/ found, just log
      console.error(`[Session] ${model}_SESSION: ${sessionId} (no .fantayspec/ to save)`);
      console.log(data);
      return;
    }

    const sessFile = path.join(specDir, 'sessions.md');
    let content = '';
    if (fs.existsSync(sessFile)) {
      content = fs.readFileSync(sessFile, 'utf8');
    } else {
      content = '# 会话状态\n';
    }

    const key = `${model}_SESSION`;
    const re = new RegExp(`- ${key}: .+`);
    const newLine = `- ${key}: ${sessionId}`;

    if (re.test(content)) {
      content = content.replace(re, newLine);
    } else {
      content = content.trimEnd() + '\n' + newLine + '\n';
    }

    fs.writeFileSync(sessFile, content);
    console.error(`[Session] Saved ${key}: ${sessionId.slice(0, 8)}...`);
  } catch (e) {
    // Silent fail - don't break the tool chain
  }
  console.log(data);
});
