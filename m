Content-Type: multipart/mixed; boundary="===============4348215977700470425=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/5] gvariant: Make sure builder outputs a zero for empty
 struct
Date: Mon, 25 Apr 2016 23:01:34 -0500
Message-ID: <571EE81E.40009@gmail.com>
In-Reply-To: <1461373807-19793-4-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4348215977700470425==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/22/2016 08:10 PM, Andrew Zaborowski wrote:
> Make sure the single byte being written by the builder is a zero.
> I had assumed grow_body would zero the newly allocated body bytes but on
> a closer look it zeros the alignment padding only.
> ---
>   ell/gvariant-util.c | 18 ++++++++++++------
>   1 file changed, 12 insertions(+), 6 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============4348215977700470425==--

