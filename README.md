# Hackbot :robot:

## Development

First, install all the required dependencies with `npm install`.

```bash
npm install
```

Then, see `.env.sample` for a list of environment variables that should be
set.

```bash
cp .env.sample .env
```

By default, hackbot will run with all the plugins in the `scripts/`
directory. If you only want to test one plugin, move all other plugins to
`disabled_scripts/`.

```bash
mv scripts/* disabled_scripts/
mv disabled_scripts/my_plugin.js scripts/
```

If your plugin requires environment variables, be sure to put them in `.env`.
See [Configuration](#configuration) for more details.

```bash
vi .env
source .env
```

Finally, run hackbot locally with `npm run dev`. You will see some logging
info and a message prompt.

```bash
$ npm run dev
[Set Jul 22 2017 23:16:06 GMT-0400 (EDT)] INFO Using default redis on localhost:6379
hackbot>
```

Now you can interact with hackbot by typing `hackbot help` or any other
supported command.

```bash
$ npm run dev
[Set Jul 22 2017 23:16:06 GMT-0400 (EDT)] INFO Using default redis on localhost:6379
hackbot> hackbot ping
hackbot> PONG
```

If you make changes, quit with `Ctrl+C` and restart hackbot with `npm run dev`.

## Configuration

Most of the plugins in `scripts/` use [hubot-conf][hubot-conf] to access
configuration values from the HackMIT Slack. That means that in order to run
them locally, you need to copy some configuration values from Slack into your
`.env`.

To do this, in Slack #botspam type `hackbot conf dump`. Find the variables
you need, and copy them into `.env`.

Be sure to follow [hubot-conf][hubot-conf] convention, mapping
`package.name.property.name` from Slack to `HUBOT_PACKAGE_NAME_PROPERTY_NAME`
in `.env`.

| Source               | Key name              | Example usage                        |
| -------------------- | --------------------- | ------------------------------------ |
| Slack                | `example.hello`       | `example.hello = "hello"`            |
| Environment variable | `HUBOT_EXAMPLE_HELLO` | `export HUBOT_EXAMPLE_HELLO="hello"` |

## Examples

You can see some more example scripts [here][examples].

[hubot-conf]: https://github.com/anishathalye/hubot-conf
[examples]: https://github.com/hubotio/hubot/blob/master/docs/scripting.md
