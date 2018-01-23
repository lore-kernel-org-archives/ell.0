Content-Type: multipart/mixed; boundary="===============0048105078708287991=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] key: Add private API for key feature detection
Date: Tue, 23 Jan 2018 15:25:56 -0600
Message-ID: <102756be-04a3-d3d8-2a49-0c810ab564d4@gmail.com>
In-Reply-To: <20180123210223.28042-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0048105078708287991==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 01/23/2018 03:02 PM, Mat Martineau wrote:
> The Diffie-Hellman, keyring restrictions, and key crypto parts of the
> l_key API depend on kernel features that were added relatively
> recently. While the affected l_key calls fail gracefully when the kernel
> doesn't implement the required feature, they do not fail in a way that
> allows unit tests to differentiate between library bugs and kernel
> support. l_key_is_supported() is a private API to check for kernel
> support.
> ---
>   ell/key-private.h | 27 +++++++++++++++++++++++++++
>   ell/key.c         | 31 +++++++++++++++++++++++++++++++
>   2 files changed, 58 insertions(+)
>   create mode 100644 ell/key-private.h
> =


All applied, thanks!

Regards,
-Denis


--===============0048105078708287991==--

