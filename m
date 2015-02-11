Content-Type: multipart/mixed; boundary="===============6934446882727834913=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/9] hashmap: Call user supplied value free function in
 insert
Date: Wed, 11 Feb 2015 07:50:38 -0600
Message-ID: <54DB5E2E.6030203@gmail.com>
In-Reply-To: <1423646869.5906.137.camel@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6934446882727834913==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Patrik,

On 02/11/2015 03:27 AM, Patrik Flykt wrote:
> On Tue, 2015-02-10 at 13:18 -0600, Denis Kenzior wrote:
>> With the current implementation, the item inserted first is
>> returned.  I don't think enforcement of unique keys is required at the
>> hashmap_insert level.
>
> As long as there is no function to read out more than one of the values
> from the hashmap, the hashmap should definitely require keys to be
> unique. It's way much simpler to require unique keys as the opposite
> situation with multiple values per key  as it is really uncommon and
> shows that the upper level data structure needs a rethought.
>

The point is, you can't just add a 'value destroy' function when we =

already provide l_hashmap_destroy_func_t as an argument.  That is just =

wrong, no ifs or buts about it.  If you want to do that, then you need =

to fix a ton of existing code to handle the new usage model.  Not just =

hack stuff in.

Duplicate key detection is just overhead, if the programmer knows that =

no duplicate keys are possible.  This is about 99% of how we do things. =

  If you need guaranteed enforcement, then just implement =

l_hashmap_replace like I suggested.

Regards,
-Denis


--===============6934446882727834913==--

