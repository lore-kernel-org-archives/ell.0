Content-Type: multipart/mixed; boundary="===============1248618107977334242=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Mon, 03 Jun 2019 22:56:07 +0200
Message-ID: <a8ff4175-dc31-ba16-ad24-36586898cdb9@geanix.com>
In-Reply-To: <30aa4457-4941-d6c0-1906-5a47eaf5857a@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1248618107977334242==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 29/05/2019 18.46, Denis Kenzior wrote:
>>
>> // off
>> l_gpio_writer_set(line, lines[0][0], 0);
>>
>> // on
>> l_gpio_writer_set(line, lines[0][0], 1);
>>
>> // many
>> l_gpio_writer_setv(line, 1, lines);
> =

> That looks fine to me.

While working at implementing this, I realized that the kernel API =

requires setting all lines at once, so I guess we have to settle with:

l_gpio_writer_set(struct l_gpio_writer *, uint32_t, uint32_t[]);

And bail out if the number of values doesn't match the number of lines =

passed when creating the writer.

// Martin

--===============1248618107977334242==--

