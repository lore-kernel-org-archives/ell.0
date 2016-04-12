Content-Type: multipart/mixed; boundary="===============3937419893199510336=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] key: Use unique key descriptors
Date: Tue, 12 Apr 2016 16:50:31 -0500
Message-ID: <570D6DA7.7010108@gmail.com>
In-Reply-To: <1460479364-14478-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3937419893199510336==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 04/12/2016 11:42 AM, Mat Martineau wrote:
> The kernel expects the key descriptor text to be unique. If a key is
> added with a descriptor that matches an existing key, the existing key
> is overwritten.
> ---
>   ell/key.c | 7 +++++--
>   1 file changed, 5 insertions(+), 2 deletions(-)
>

All four applied, thanks.

Regards,
-Denis


--===============3937419893199510336==--

