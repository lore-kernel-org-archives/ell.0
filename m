Content-Type: multipart/mixed; boundary="===============7264885121559333320=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2] [RFC PATCH] tester: Add framework for serialized test
 execution
Date: Mon, 15 Mar 2021 14:46:35 -0500
Message-ID: <fa8ec394-7af5-8369-57c9-d4a60d4344e6@gmail.com>
In-Reply-To: <20210315165926.17690-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7264885121559333320==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Inga,

On 3/15/21 11:59 AM, Inga Stotland wrote:
> This adds a framework for running series of noninteractive tests
> that are capable of executing more complex scenarios than a usual unit
> test.
> =

> The framework enables staging of a test case processing:
> - test pre-setup: can be used to prepare an initial testing environment
>                    potentially common to between several test cases, e.g.,
> 		  put an emulator in a certain well known state.
> - test setup: used to setup conditions specific for the test case
> - test run: execute actual test case
> - test teardown: Cleans up after test setup
> - test post-teardown: Cleans up after test pre-setup
> =

> Additional command line options allow to run a selected group of tests
> based either on a group prefix of the test name or a substring in test
> description.
> ---
>   Makefile.am  |   6 +-
>   ell/ell.h    |   1 +
>   ell/ell.sym  |  21 ++
>   ell/tester.c | 780 +++++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/tester.h |  97 +++++++
>   5 files changed, 903 insertions(+), 2 deletions(-)
>   create mode 100644 ell/tester.c
>   create mode 100644 ell/tester.h
> =


I went ahead and applied this with a minor tweak to the includes (adding =

#include "useful.h") due to recent internal includes reorg.

Regards,
-Denis

--===============7264885121559333320==--

