hubot-last.fm
---

This is a Hubot plugin for keeping track of what team members are scrobbling to Last.fm.

## Installation

Install `hubot-last.fm` as a dependency of your Hubot and add `"hubot-last.fm"` to your `external-scripts.json` list. Make sure that you have a [Last.fm API key](http://www.last.fm/api/accounts) set as `HUBOT_LAST_FM_API_KEY` in your environment.

## Usage

You can add users two ways:

1. Place a seed JSON file in `data/last-fm-users.json` with an object mapping chat names to Last.fm usernames. For example,
```json
{
    "derek": "labetephoque"
}
```
2. Add new usernames in chat, using `add last.fm user <user name> <last.fm user name>`. Keep in mind that this is only stored in memory, though, so it will go away if you restart your Hubot.

## Notes

I've only tested this in Slack, so it's possible that integrations with other chat clients won't work. If that's the case, let me know.

Oh, and I welcome requests for more actions.
