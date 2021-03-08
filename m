Content-Type: multipart/mixed; boundary="===============9186060997010340546=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] [RFC PATCH] tester: Add framework for serialized test
 execution
Date: Mon, 08 Mar 2021 16:19:30 -0600
Message-ID: <36d7f7a7-c4d6-eff3-66cd-4654bfe96dcd@gmail.com>
In-Reply-To: <20210305213733.131497-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9186060997010340546==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Inga,

On 3/5/21 3:37 PM, Inga Stotland wrote:
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
>   ell/tester.c | 786 +++++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/tester.h |  94 ++++++

Hmm, ell.sym entries?

>   3 files changed, 884 insertions(+), 2 deletions(-)
>   create mode 100644 ell/tester.c
>   create mode 100644 ell/tester.h
> =


<snip>

> +
> +static char *tester_name;
> +
> +static struct l_queue *test_list;
> +static const struct l_queue_entry *test_entry;
> +static struct timeval tester_start;
> +
> +static bool option_list;
> +static const char *option_prefix;
> +static const char *option_string;
> +
> +static bool terminated;
> +

Curious.  This tester framework is part of the main ell library, so I would=
 have =

assumed it is a 'class' so to speak.  But you use static vars here.  So is =

l_tester only used from a dedicated binary?

If not, do the l_tester_* signatures need to be updated to take an l_tester =

instance and appropriate constructors / destructors defined?

<snip>

> +
> +void *l_tester_get_data(void)

LIB_EXPORT?

> +{
> +	struct test_case *test;
> +
> +	if (!test_entry)
> +		return NULL;
> +
> +	test =3D test_entry->data;
> +
> +	return test->user_data;
> +}
> +
> +static double get_elapsed_time(struct timeval *base)
> +{
> +	static struct timeval now, elapsed;
> +
> +	gettimeofday(&now, NULL);
> +	timersub(&now, base, &elapsed);
> +

Have you considered using l_time* from ell/time.h?

> +	return elapsed.tv_sec + ((double) elapsed.tv_usec) / 1000000;
> +}
> +

<snip>

The rest of the code seems straightforward and nothing else really jumped o=
ut at me.

Regards,
-Denis
--===============9186060997010340546==--

