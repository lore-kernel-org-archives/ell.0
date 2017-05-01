Content-Type: multipart/mixed; boundary="===============3058735986379314265=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] unit: Test netlink multicast group registration
Date: Mon, 01 May 2017 11:00:41 -0500
Message-ID: <5de72d8d-edad-c851-5253-3c50f0954b51@gmail.com>
In-Reply-To: <1493413000-14282-1-git-send-email-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3058735986379314265==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 04/28/2017 03:56 PM, Ossama Othman wrote:
> Register for the rtnetlink RTNLGRP_LINK multicast group to test the
> ELL netlink multicast group registration code.  Only registration and
> deregistration is performed for now.  An actual RTNLGRP_LINK multicast
> notification is not triggered.
> ---
>  unit/test-netlink.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
>

Applied, thanks.

Regards,
-Denis


--===============3058735986379314265==--

