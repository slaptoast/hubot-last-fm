hubot-last.fm
---

This is a Hubot plugin for keeping track of what team members are scrobbling to last.fm.

## Installation

Install `hubot-last.fm` as a dependency of your Hubot and add `"hubot-last.fm"` to your `external-scripts.json` list. Make sure that you have a [last.fm API key](http://www.last.fm/api/accounts) set as `HUBOT_LAST_FM_API_KEY` in your environment.

## Usage

You can add users two ways:

First (recommended, but optional), you can place a seed JSON file in `<project root>/data/last-fm-users.json` with an object mapping chat names to last.fm usernames. For example,
```json
{
    "derek": "labetephoque"
}
```

Second, add new usernames in chat, using `add last.fm user <user name> <last.fm user name>`. Keep in mind that this is only stored in memory, though, so it will go away if you restart your Hubot.

## Notes

I've only tested this in Slack, so it's possible that integrations with other chat clients won't work. If that's the case, let me know.

Oh, and I welcome requests for more actions.
