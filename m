Content-Type: multipart/mixed; boundary="===============7043154962619121273=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Wed, 05 Jun 2019 11:08:59 -0500
Message-ID: <f15e6483-33e6-bbe9-84ce-ee27303a59c9@gmail.com>
In-Reply-To: <a8ff4175-dc31-ba16-ad24-36586898cdb9@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7043154962619121273==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Martin,

On 06/03/2019 03:56 PM, Martin Hundeb=C3=B8ll wrote:
> Hi Denis,
> =

> On 29/05/2019 18.46, Denis Kenzior wrote:
>>>
>>> // off
>>> l_gpio_writer_set(line, lines[0][0], 0);
>>>
>>> // on
>>> l_gpio_writer_set(line, lines[0][0], 1);
>>>
>>> // many
>>> l_gpio_writer_setv(line, 1, lines);
>>
>> That looks fine to me.
> =

> While working at implementing this, I realized that the kernel API =

> requires setting all lines at once, so I guess we have to settle with:
> =

> l_gpio_writer_set(struct l_gpio_writer *, uint32_t, uint32_t[]);
> =

> And bail out if the number of values doesn't match the number of lines =

> passed when creating the writer.

I think this is fine for the first iteration.  But one thing occurs to =

me is that since we have exclusive access to the GPIO for writing, we =

still can support the vararg or offset variation by simply storing all =

the values we set into the GPIO and maintain/buffer the values =

persistently.  So if the user provides just a single value out of N, =

then we just update that value and set the whole thing in its entirety.

This can lead to a bit nicer API where you can simply do:

l_gpio_writer_set(writer, "gpio_line_label", value);

With the above, we can safely drop the whole set_one / get_one and use =

the much nicer form above.

> =

> // Martin

Regards,
-Denis

--===============7043154962619121273==--

