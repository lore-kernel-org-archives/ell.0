Content-Type: multipart/mixed; boundary="===============6882439586304775194=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/5] ell: Use __typeof__ instead of typeof in headers.
Date: Tue, 30 Oct 2018 09:06:03 +0100
Message-ID: <9DB16C06-D65C-4485-B07F-523834E778CC@holtmann.org>
In-Reply-To: <20181029200715.28427-2-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6882439586304775194==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

> The typeof keyword is disabled by gcc when compiling with the -ansi or
> -std command line options.  Use __typeof__ instead.  This is
> particularly important for headers exposed to users that contain uses
> of typeof.
> ---
> ell/private.h | 2 +-
> ell/util.h    | 8 ++++----
> 2 files changed, 5 insertions(+), 5 deletions(-)

patch has been applied.

Regards

Marcel


--===============6882439586304775194==--

