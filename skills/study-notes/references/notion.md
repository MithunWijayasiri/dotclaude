# Notion output

Notion-flavored markdown via the Notion connector. Unsure of syntax → read `notion://docs/notion-flavored-markdown-spec` first.

## Editing

- Fetch the page before every edit; the user may have changed it since.
- Existing page → `update-page` with `update_content`, anchored on exact strings (heading or `Objective` line + following spacer). Never `replace_content`: it drops the user's images and edits.
- Empty page with only a heading → replace that heading with heading + boilerplate in one call.
- No page given → create a private draft (`creation_mode: "draft"`), share the link, offer to move it.
- Large fetch saved to a file → read it in chunks or hand it to a subagent.

## Blocks

Spacer between blocks, divider between chapters:

```
<p />

---
```

Chapter keywords, gray detail:

```
<span color="gray">Keywords: system under test, test automation</span>
```

LO heading + objective:

```
### 1.1.1 Advantages & Disadvantages of Test Automation 🟩

<code>Objective</code>: Explain the advantages and disadvantages of test automation

<p />
```

Definition line:

```
<i><span color="yellow">test automation = using tools to set up, run and check tests</span></i>
```

Callout:

```
<callout icon="💡" color="gray_bg">
<b>Limitations</b>

- Not all manual tests can be automated
</callout>
```

Table — `header-row` for column headers, add `header-column` when the first column labels rows. Multi-line cell → `- a<br />- b`.

```
<table header-row="true" header-column="true">
<colgroup>
<col width="170" />
<col width="510" />
</colgroup>
<tr>
<td>
Layer
</td>
<td>
Contains
</td>
</tr>
<tr>
<td>
Core libraries
</td>
<td>
- SUT-independent<br />- Reusable across projects
</td>
</tr>
</table>
```

Colors: `<span color="green">`, `<span color="red">`, emphasis `<b><span color="pink">term</span></b>`.
