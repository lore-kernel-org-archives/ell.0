Content-Type: multipart/mixed; boundary="===============2289098136500535407=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCHv5] gpio: add get/set helpers for GPIO lines
Date: Mon, 17 Jun 2019 15:39:31 -0500
Message-ID: <0440af99-d0f2-21c2-df32-70ed507ea656@gmail.com>
In-Reply-To: <20190617100837.66501-1-martin@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2289098136500535407==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Martin,

On 06/17/2019 05:08 AM, Martin Hundeb=C3=B8ll wrote:
> The Linux kernel GPIO api operates with chips, lines, handles, and events.
> =

> The chip and line structures represent info about gpio chips, and gpio
> lines, respectively. They are used to e.g. lookup a line with a certain
> name, and/or line flags.
> =

> The handle structure is used to "obtain" a handle to one or more gpio
> lines on a chip. Until the file descriptor in this handle is closed, the
> gpio lines cannot be used by others. The same file descriptor is used
> when setting or getting the line values (one can also set the initial
> value when obtaining handles for output lines).
> =

> The event structure is used to get a file descriptor that can be used
> with select/poll to wait for changes in line levels.
> =

> This commit adds support for setting and getting values for one or more
> gpio lines. So far three structures are implemented:
> =

>   l_gpio_chip
>   l_gpio_writer
>   l_gpio_reader
> =

> The chip structure is used to look up line info, and to find line
> offsets for a certain label. The chip and offset is then used to
> instantiate writers and readers.
> =

> The writer and reader are created with one of more offsets on a certain
> chip. For the writer case, the offsets are accompanied with the default
> output values to set when requesting the gpio lines.
> =

> Functionality that could be implemented, but is postponed until the need
> arises includes:
> =

>   * waiting for events
>   * one-shot wrappers that don't hold on to gpio lines
> =


Applied, thanks.

Regards,
-Denis


--===============2289098136500535407==--

