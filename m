Content-Type: multipart/mixed; boundary="===============4856218554226868303=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: Debug logging with ell
Date: Tue, 24 Apr 2018 14:35:23 -0700
Message-ID: <CAPyD+=AE=7WiOqCumVyvNCtPpWFFMiZKk6eeg0bLeOVcqHETxw@mail.gmail.com>
In-Reply-To: <9b01b52a-c2f5-9abf-f1e0-cfeea4b56053@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4856218554226868303==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Tue, Apr 24, 2018 at 1:30 PM, Denis Kenzior <denkenz@gmail.com> wrote:>
>> Quick question: can I use l_debug() when I am dynamically linking with
>> installed ell library (i.e., the one created with make install and
>> linked as -lell)?
>> Calling l_debug() generates no output, l_info() works just fine.
>>
>
> I suspect you're the first to try this, so doesn't surprise me that it
> doesn't work.  I imagine the current setup fails because the shared libra=
ry
> has its own section and the executable has its own.
>
> Probably can be solved with some macro magic, but will require a bit of
> surgery inside ell...

This used to work for me, but prior to today the last time I tried
enabling debug logging code was probably a couple of months ago.

-Ossama

--===============4856218554226868303==--

