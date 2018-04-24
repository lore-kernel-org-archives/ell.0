Content-Type: multipart/mixed; boundary="===============8413875672024289026=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: Debug logging with ell
Date: Tue, 24 Apr 2018 14:33:32 -0700
Message-ID: <CAPyD+=CUSmt1JUmvKJ8q4=1vLg52d2_BZmumWV=wC0=rgQBaDQ@mail.gmail.com>
In-Reply-To: <1524599816.3034.23.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8413875672024289026==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Inga,

On Tue, Apr 24, 2018 at 12:56 PM, Stotland, Inga
<inga.stotland@intel.com> wrote:
> On Tue, 2018-04-24 at 10:35 -0700, Othman, Ossama wrote:
>> On Tue, Apr 24, 2018 at 9:33 AM, Stotland, Inga <inga.stotland@intel.
>> com> wrote:
>> >
>> > Quick question: can I use l_debug() when I am dynamically linking
>> > with
>> > installed ell library (i.e., the one created with make install and
>> > linked as -lell)?
>> > Calling l_debug() generates no output, l_info() works just fine.
>> >
>> > When I link with libell-private, l_debug works as expected.
>> > Something
>> > to do with debug mem sections?
>>
>> Try enabling debug logging at run-time, e.g.:   l_debug_enable("*");
>
> I do have the following statements in my code:
> l_log_set_stderr();
> l_debug_enable("*");

I suppose l_debug() wouldn't have worked when you linked against
libell-private otherwise.  Sorry.  I missed that. :)

In any case, this certainly used to work.  I was able to reproduce the
same problem you ran into as well, but I'm not sure what changed.

-Ossama

--===============8413875672024289026==--

