Content-Type: multipart/mixed; boundary="===============4762976459649251169=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 0/2] l_strv_append() test and minor patch
Date: Sun, 17 Feb 2019 20:41:58 -0600
Message-ID: <c16c7a6e-a788-00cb-7e55-72db90ea1e79@gmail.com>
In-Reply-To: <20190214204549.26138-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4762976459649251169==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 02/14/2019 02:45 PM, Ossama Othman wrote:
> The l_strv_append() function needlessly post-incremented an array
> index value prior to returning.  Drop the post-increment, and a
> l_strv_append() unit test.
> =


Both applied, thanks.

Regards,
-Denis


--===============4762976459649251169==--

