Content-Type: multipart/mixed; boundary="===============7355706407732319968=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 1/2] time: basic utility for getting the system time
Date: Wed, 23 Jan 2019 17:19:18 -0600
Message-ID: <920d638f-96ab-4d72-6b83-0fc224197ac4@gmail.com>
In-Reply-To: <20190123221159.24449-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7355706407732319968==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 01/23/2019 04:11 PM, James Prestwood wrote:
> Timeouts are sometimes overkill for long timeouts, or timeouts that
> don't require being immediately serviced once expired. For this
> reason the 'time' module was added which allows you to get the system
> clock time, as well as some basic APIs to check if two time values are
> before/after one another, calculating an offset from a start time, and
> finding the diff between two time values. This allows an application
> to handle its own timeouts lazily with no tie to the main loop.
> =

> The APIs were modeled after the kernel APIs in jiffies.h
> ---
>   Makefile.am |  6 +++--
>   ell/ell.h   |  1 +
>   ell/ell.sym |  7 ++++++
>   ell/time.c  | 72 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/time.h  | 67 +++++++++++++++++++++++++++++++++++++++++++++++++
>   5 files changed, 151 insertions(+), 2 deletions(-)
>   create mode 100644 ell/time.c
>   create mode 100644 ell/time.h
> =


Both applied, thanks.

Regards,
-Denis


--===============7355706407732319968==--

