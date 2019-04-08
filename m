Content-Type: multipart/mixed; boundary="===============2424323966054962238=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 0/2] Fix unit tests under Clang build.
Date: Mon, 08 Apr 2019 15:28:35 -0500
Message-ID: <04895fbd-4ad6-fea0-809d-f462549fa0fa@gmail.com>
In-Reply-To: <20190408201235.10846-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2424323966054962238==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 04/08/2019 03:12 PM, Ossama Othman wrote:
> This patch set addresses unit test build warnings and a segmentation
> fault when ELL is built with the Clang C compiler.
> =

> Ossama Othman (2):
>    unit: Remove unnecessary NULL pointer checks.
>    unit: Fixed a test-dbus-message seg fault.
> =

>   unit/test-dbus-message.c | 2 +-
>   unit/test-dhcp.c         | 6 +++---
>   2 files changed, 4 insertions(+), 4 deletions(-)
> =


Both applied, thanks.

Regards,
-Denis

--===============2424323966054962238==--

