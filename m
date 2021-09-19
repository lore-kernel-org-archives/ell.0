Content-Type: multipart/mixed; boundary="===============7019377528258201817=="
MIME-Version: 1.0
From: Simon Maurer <mail at maurer.systems>
To: ell at lists.01.org
Subject: AIO support
Date: Sun, 19 Sep 2021 17:12:13 +0000
Message-ID: <61f114ce-ed19-980d-8b97-1eb3b30eee51@maurer.systems>

--===============7019377528258201817==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi
Awesome library! Thank you very much. I'm using it for an embedded linux =

application with not so strict real time constraints. Problem is, I need =

non blocking file access, because the memory card on my system is quite =

slow. It turns out that this whole non-blocking access doesn't work for =

files, so now I'm using the POSIX AIO interface and I've integrated it =

into ELL:
https://github.com/mausys/ell/blob/master/ell/aio.c
(But needs to be linked against rt)
This is just a draft and it also works on top of ELL, but maybe other =

applications need this too.

Best regards,
Simon Maurer
--===============7019377528258201817==--

