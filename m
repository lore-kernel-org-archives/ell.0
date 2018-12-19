Content-Type: multipart/mixed; boundary="===============4069937436950375512=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/9] tls: Don't send Client Hello in l_tls_new
Date: Wed, 19 Dec 2018 10:04:30 -0600
Message-ID: <0892843d-9b54-0347-f536-48e8c57daad7@gmail.com>
In-Reply-To: <20181219005800.12013-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4069937436950375512==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 12/18/2018 06:57 PM, Andrew Zaborowski wrote:
> Give the user time to set up the tls instance's optional parameters --
> those that can not be passed as parameters of l_tls_new, before sending
> the Client Hello message in client mode.  We now send the message from
> l_tls_start which has to be called after the optional setup is done,
> e.g. set_cacert, set_auth_data, set_debug are called.  This way Client
> Hello can avoid proposing cipher suites that would not have worked if
> they were negotiated, due to bad certificate type.  It also allows us to
> output debug messages in the Client Hello sending code, and will allow
> to add methods to define security profiles.
> ---
>   ell/ell.sym       |  1 +
>   ell/tls-private.h |  1 +
>   ell/tls.c         | 48 ++++++++++++++++++++++++++++-------------------
>   ell/tls.h         |  3 +++
>   4 files changed, 34 insertions(+), 19 deletions(-)

Patches 1-4 applied, thanks.

Regards,
-Denis

--===============4069937436950375512==--

