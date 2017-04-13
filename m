Content-Type: multipart/mixed; boundary="===============2514643641594782025=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2] unit: Test generic netlink family registration
Date: Thu, 13 Apr 2017 14:18:19 -0500
Message-ID: <4c1e6048-57ab-ee4a-44e4-5b48da07142a@gmail.com>
In-Reply-To: <1492027770-28419-1-git-send-email-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2514643641594782025==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 04/12/2017 03:09 PM, Ossama Othman wrote:
> Verify that genl family registration works by attempting to set a
> family_appeared watch for the "nlctrl" family, and registering a
> callback for it.  The "nlctrl" generic netlink family always exists in
> the kernel so it is a suitable family to use for testing the
> family_appeared watch and related family registration operations.
> ---
>  unit/test-genl.c | 114 +++++++++++++++++++++++++++++++++++++++++++++----=
------
>  1 file changed, 93 insertions(+), 21 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============2514643641594782025==--

