Content-Type: multipart/mixed; boundary="===============1484670661435711572=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 0/2] Make some ELL headers completely self-contained.
Date: Wed, 08 Mar 2017 15:34:57 -0600
Message-ID: <6a4f0746-d693-0495-bc51-70e07529dab8@gmail.com>
In-Reply-To: <1489004965-19931-1-git-send-email-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1484670661435711572==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 03/08/2017 02:29 PM, Ossama Othman wrote:
> These patches address some compile-time errors encountered when
> attempting to use functions and macros declared in installed ELL
> headers.  The headers in question were not completely self-contained.
>
> Ossama Othman (2):
>   main: Fixed missing uint32_t typedef error
>   log: Fixed missing L_STRINGIFY macro definition
>

Both applied.  Though I wonder why you're not including ell/ell.h and =

including these headers individually.

Regards,
-Denis


--===============1484670661435711572==--

