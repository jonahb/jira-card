# jira-card

## Setup

Run `jira-card`. You'll be prompted for:

* Username (_not_ the same as your email; see your JIRA profile)
* Password
* JIRA Site URL
* Context Path (blank for sites hosted on atlassian.net)
* Your initials (for branch prefixes)

These will be saved in `~/.jira-card/config.yml`. _Warning:_ Configuration data is stored in plain text.

## Issue-type Prefixes

To prepend a string based on the issue type to suggested branch names, create `~/.jira-card/issue_prefixes.yml`. This file should contain a hash mapping issue type IDs to prefixes.

## Examples

Print the key of the first issue assigned to the current user

```
$ jira-card
WEB-1234
```

Print the URI of the first issue assigned to the current user

```
$ jira-card uri
https://company.atlassian.net/browse/WEB-1234
```

Print a suggested branch name

```
$ jira-card branch
bugfix/jsb-WEB-1234-fix-bluescreens
```

Print the keys of all issues assigned to the current user

```
$ jira-card -a
WEB-1234
WEB-5678
```

Open a card in the browser

```
$ jira-card uri | xargs open
```

Place a card's URI on the clipboard

```
$ jira-card uri | pbcopy
```

Open a pull request with the issue URI as the message

```
$ hub pull-request -m `jira-card uri`
```
