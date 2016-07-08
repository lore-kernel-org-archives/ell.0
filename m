Content-Type: multipart/mixed; boundary="===============1151121379131077526=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] dbus-service: Allow property setters to return errors
Date: Fri, 08 Jul 2016 12:41:50 -0500
Message-ID: <577FE5DE.2060503@gmail.com>
In-Reply-To: <1467993318-11918-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1151121379131077526==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 07/08/2016 10:55 AM, Andrew Zaborowski wrote:
> Allow the property setter functions to synchronously return a message
> pointer if they need to return an error.  On success complete still
> needs to be called because the NULL return value couls also mean that
> the setter will complete asynchronously.
> ---
>   ell/dbus-service.c | 21 +++++++++++++++------
>   ell/dbus-service.h |  2 +-
>   2 files changed, 16 insertions(+), 7 deletions(-)
>

All three applied, thanks.

Regards,
-Denis


--===============1151121379131077526==--

