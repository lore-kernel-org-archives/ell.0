Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id A2E076ADC
	for <ell@lists.linux.dev>; Tue, 25 Apr 2023 16:24:48 +0000 (UTC)
Received: from smtpclient.apple (p5b3d2302.dip0.t-ipconnect.de [91.61.35.2])
	by mail.holtmann.org (Postfix) with ESMTPSA id 8D6D0CECED;
	Tue, 25 Apr 2023 18:24:40 +0200 (CEST)
Content-Type: text/plain;
	charset=us-ascii
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3696.120.41.1.3\))
Subject: Re: Static array indices in function parameter declarations
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <b0400fee-c228-7505-8e1e-c4aff185da9b@gmail.com>
Date: Tue, 25 Apr 2023 18:24:39 +0200
Cc: Brandon Cheo Fusi <fusibrandon13@gmail.com>,
 ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <79F12F42-0936-4661-82BF-DFB4196BBA4E@holtmann.org>
References: <CAEVJM+pjy7k+to4uYCVBsBL9U0DDJzZ08DLtzvO5SrH-PS6Lxg@mail.gmail.com>
 <b0400fee-c228-7505-8e1e-c4aff185da9b@gmail.com>
To: James Prestwood <prestwoj@gmail.com>
X-Mailer: Apple Mail (2.3696.120.41.1.3)

Hi James,

>> I'm currently using ell for talking to dbus, and have found it way
>> more convenient and easier to use as compared to gdbus, or any of the
>> other bindings I've looked at. So many thanks.
>> The extern "C"  usage in the header files show the library is allowed
>> to be compiled with C++ code. However the usage of the C99 feature
>> that allows one to declare the index of the argument array using the
>> 'static' keyword in some header files (like rtnl.h:110) seems to
>> prevent this.
>> Is there a workaround for this issue?  Or should I submit a patch =
that
>> removes all usage of this feature.
>=20
> Is this you're only issue compiling ELL with C++ code? I ask because I =
quickly tried:
>=20
> ~/ell$ g++ -o ell/rtnl.o ell/rtnl.c -I.
>=20
> And I got a TON of errors. Mostly void* pointer arithmetic and missing =
casts from void* to other types.

and that was never the goal. You always have to build ELL with a C =
compiler.

That you might be able to link against -lell from a C++ is an option, =
but
our work just including the C++ boilerplate in the headers. And then it
stopped exactly there. So we need external contributions if things do =
not
work.

Regards

Marcel

