Content-Type: multipart/mixed; boundary="===============8196398865267662596=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: ell/main.c Memory leak
Date: Fri, 03 Jun 2016 17:16:00 -0500
Message-ID: <575201A0.5040304@gmail.com>
In-Reply-To: <CAOq732Jy-EE95rEvK8wLNOWXfC-ZJNq8b-iQmyqzSE-ivHfA1Q@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8196398865267662596==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

 > I think I saw this but concluded it will go away when the Address

It will, and this one is rather benign, but I want to run have clean =

valgrind runs...

> property format gets changed to be a proper string.  One thing that
> could work to avoid this in the future is to exit from create_epoll if
> epoll_terminate is true, IIRC there was something else that already

Yes, this is another possibility.  Prevent various main event loops =

elements from being created if l_main_quit has been called...

> prevented l_main_run from being used multiple times.  Also it's a very
> small leak that only happens on exit...

Regards,
-Denis


--===============8196398865267662596==--

