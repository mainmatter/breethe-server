# Breethe Server

**This is the server for [Breethe](https://breethe.app), a Progressive Web App
built by [Mainmatter](https://mainmatter.com). We build custom web and mobile
solutions for our clients to rely on.**

Breethe allows instant access to up to date air quality data for locations in Europe. Pollution and global warming are getting worse rather than
better and affect everyone's daily lives. Easily accessible data on how bad
things actually are might help raising attention and awareness 🌳💨

The data is retrieved from the [European Environment Agency](https://www.eea.europa.eu/).

## The Stack

[![Build Status](https://travis-ci.org/mainmatter/breethe-server.svg?branch=master)](https://travis-ci.org/mainmatter/breethe-server)

Breethe is built with [Phoenix](http://phoenixframework.org), the productive,
reliable and fast web framework that builds on top of
[Elixir](https://elixir-lang.org) - which in turn builds on top of
[Erlang](https://www.erlang.org). It uses PostgreSQL for data storage and
exposes data to the
[client application](https://github.com/mainmatter/breethe-client) as
[json:api](http://jsonapi.org).

We built Breethe for maximum efficiency and performance. The server is a caching
proxy that caches, filters and processes data obtained from the
[European Environment Agency](https://www.eea.europa.eu/).

**This project is still in a relatively early stage. There are likely still
bugs and there is definitely lots of room for even more improvement.** If you
run into any problems, would like to give feedback or help improve this, please
reach out on github!

## License

Breethe is developed by and &copy; [Mainmatter GmbH](http://mainmatter.com) and
contributors. While we invite everyone to use this for inspiration and
reference, we do not grant a license to reuse or redistribute this in any form.

If you would like to use this for educational or charitable purposes, please
reach out at breethe@mainmatter.com
