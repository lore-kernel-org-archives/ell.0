Content-Type: multipart/mixed; boundary="===============1088367840622502026=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] log: Fix systemd journal PRIORITY field logging
Date: Fri, 10 Mar 2017 09:52:31 -0600
Message-ID: <e01729e7-ccf0-2db5-dab7-18a5e90ff60d@gmail.com>
In-Reply-To: <1489099682-8621-1-git-send-email-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1088367840622502026==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 03/09/2017 04:48 PM, Ossama Othman wrote:
> When logging messages to the systemd journal the trailing line feed
> character was truncated since the message length was incorrectly
> reduced by one.  That resulted in the next systemd journal field, in
> this case PRIORITY, being written as part of the logged message string
> (e.g. "fooPRIORITY=3D6") rather than as a separate journal field.
> ---
>  ell/log.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>

Applied, thanks.

Regards,
-Denis


--===============1088367840622502026==--

