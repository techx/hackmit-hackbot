# hackbot

See `.env.sample` for a list of environment variables that should be set.

# Running hackbot locally

First, run `npm install` to install all the required dependencies.

Test hackbot by running `npm run dev`. However, some plugins
will not behave as expected unless you set the 
[environment variables](#configuration).

You'll see some start up output and a prompt:

```
[Set Jul 22 2017 23:16:06 GMT-0400 (EDT)] INFO Using default redis on localhost:6379
hackbot>
```

Then you can interact with hackbot by typing `hackbot help` or any
other supported command.

```
hackbot> hackbot ping
hackbot> PONG
```

# Configuration

Most of the scripts in `scripts/` use [hubot-conf][hubot-conf]
to access configuration values from the HackMIT Slack. That means
that in order to run them locally, you need to copy them from
Slack into your enviroment variables.

To do this, in Slack #botspam type `hackbot conf dump`. Find the
variables you need, and copy them into a `.env` file. 

Be sure to follow [hubot-conf][hubot-conf] convention, mapping
`package.name.property.name` from Slack to 
`HUBOT_PACKAGE_NAME_PROPERTY_NAME` in `.env`.

As an example, if I want the property `example.hello = "hello"`, I
 would write the line `export HUBOT_EXAMPLE_HELLO="hello"` in `.env`.

To minimize work, you can move the scripts you don't need to use
into `disabled_scripts/`, so you only need to copy configuration
values for the scripts you're changing.

Remember to `source .env` and restart hackbot with `npm run dev`
after you make a change!

[hubot-conf]: https://github.com/anishathalye/hubot-conf
