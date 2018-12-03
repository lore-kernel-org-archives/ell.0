Content-Type: multipart/mixed; boundary="===============6765755454452460806=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/9] ecdh: moved ECDH from IWD
Date: Mon, 03 Dec 2018 12:41:53 -0600
Message-ID: <c9844035-63dc-fb09-0f48-c86b8934a2af@gmail.com>
In-Reply-To: <bb8e881bfcf957df7554b21278921cbffa79046e.camel@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6765755454452460806==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

>> bool l_ecdh_generate_key_pair(const struct l_ecc_curve *curve,
>> 				struct l_ecc_point *out_public,
>> 				struct l_ecc_constant *out_private);
>> ?
> Yes it is just a point on the curve, but I don't think that most users
> of this API need or care to know to that level of detail. Also,

But if we pass in void * and a length, don't they have to care even to a =

greater degree?  I mean they need to know how many bytes they should =

pass in for example.  And then they must somehow *know* that they want a =

compressed point or uncompressed and pass in the appropriate number of =

bytes. And then do the conversion to network order.

You could just make ecc_point take care of all these details.

> generating the shared secret supports compressed coordinates where only
> the X coordinate is given. In this case the half public key is coming
> from the network, so its much more convenient just feeding it that raw
> data that converting it to a point.

You still need to validate what is coming over the network and convert =

it from network byte order.  The constructor for ecc_point could do this =

for you.

Regards,
-Denis

--===============6765755454452460806==--

