# Harvest for Touchbar
This is a simple script for [BetterTouchTool](https://folivora.ai/) which
allows users to control their currently active timer on Harvest.

![Harvest for Touchbar in action](https://i.imgur.com/6lh8MXv.jpg)

The extension is essentialy a touchbar-based duplicate of Harvest for Mac's
menu bar.

## Installation
Before getting started, please ensure you have
[BetterTouchTool](https://folivora.ai/downloads), Ruby, and
[Bundler](https://bundler.io/) installed on your on your Mac.

Once you have these packages installed cd into a directory you're not likely to
accidentally delete (as that will break the widget) and clone the repository:

```
$ git clone https://github.com/stevenleeg/harvest-touchbar.git harvest-touchbar
```

Next you'll need to generate a personal access token from [Harvest's developer
console](https://id.getharvest.com/developers) for the widget to access your
account. Once you've generated your credentials you'll need to create a file,
`config.yml` with the following contents:

```yaml
harvest_token: [auth token here]
harvest_account_id: [account id here]
```

We'll also need to install some Ruby dependencies by running:

```
$ bundle
```

Finally we'll generate a JSON configuration snippet used to add the widget to BTT
and copy it into your system clipboard:

```
$ ruby harvest.rb | pbcopy
```

Once copied, you can open BTT's touchbar configuration screen and add the
widget by right clicking on the list of widgets and clicking "Paste from JSON
in clipboard":

![BTT](https://i.imgur.com/lgTWEnR.png)

*Voilà!* You should now have a functional Harvest widget in your touchbar. Give
it a tap to start/stop your latest timer.
