Content-Type: multipart/mixed; boundary="===============8130770641544012467=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Fri, 14 Dec 2018 11:18:44 -0600
Message-ID: <0ae81caf-99ef-91c3-8fb7-a673024ba19e@gmail.com>
In-Reply-To: <cd28668a-5046-0f7a-1efe-ced22be4adcf@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8130770641544012467==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Martin,

> I am not sure if the l_gpio_chip_{set,get}_line_value() functions are =

> the right approach.
> =

> I am working on a (ofono) user for this class, where I need to lookup a =

> line, and store it in a private data structure. With the l_gpio_chip + =

> line number approach I need to have two gpio-related members in my =

> private struct.
> =


Never worked with GPIOs, so this may be a silly question, but...

How does one figure out the line number that is needed?  You just have =

to know based on some docs?

> If we instead required callers to first create a l_gpio_chip instance, =

> and use that to get l_gpio_line instances, then we could store a =

> reference to the chip in the line instance, which would make it simpler =

> for users to keep a reference to line.

Possible, but the question is how does the kernel behave...

> =

> That creates a new set of problems though, where l_gpio_line instances =

> can get dangling references to freed l_gpio_chip instances. Maybe a list =

> of references to "child" lines in l_gpio_chip could be maintained and =

> freed when freeing the l_gpio_chip "parent".
> =


You have the main /dev/chip file descriptor and you have a file =

descriptor returned from the GPIO_GET_LINEHANDLE_IOCTL.  What happens to =

the fds returned by GPIO_GET_LINEHANDLE_IOCTL if the main /dev/chip fd =

is closed?

There's no hotplug/unplug with gpio devices right?  So you can count of =

the /dev/chip & fd to be owned exlusively by the ell client?

Regards,
-Denis

--===============8130770641544012467==--

