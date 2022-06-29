Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 58BF72F33
	for <ell@lists.linux.dev>; Wed, 29 Jun 2022 14:06:01 +0000 (UTC)
Received: from smtpclient.apple (p4fefc2ee.dip0.t-ipconnect.de [79.239.194.238])
	by mail.holtmann.org (Postfix) with ESMTPSA id D0979CED43;
	Wed, 29 Jun 2022 15:59:33 +0200 (CEST)
Content-Type: text/plain;
	charset=us-ascii
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3696.100.31\))
Subject: Re: [PATCH] build: Check for openssl legacy provider requirement
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <20220519224828.91435-1-mathew.j.martineau@linux.intel.com>
Date: Wed, 29 Jun 2022 15:59:33 +0200
Cc: ell@lists.01.org,
 zhw2101024@gmail.com,
 ell@lists.linux.dev
Content-Transfer-Encoding: 7bit
Message-Id: <C71F32EA-3360-4E39-B796-DAF102D3E487@holtmann.org>
References: <20220519224828.91435-1-mathew.j.martineau@linux.intel.com>
To: Mat Martineau <mathew.j.martineau@linux.intel.com>
X-Mailer: Apple Mail (2.3696.100.31)

Hi Mat,

> OpenSSL 3 introduced some command line incompatibilities and removed
> some old algorithms from the defaults. This broke some of the unit test
> cert generation commands on distros like Ubuntu 22.04 and Fedora 36.
> 
> Detect support of "providers" by the system openssl command and insert
> the necessary command line parameters to enable legacy algorithms for
> openssl v3, but leave the commands unchanged for older openssl versions.
> ---
> 
> Tested on Ubuntu 22.04, Fedora 36, and Fedora 35.
> 
> ---
> Makefile.am  | 26 ++++++++++++++++++--------
> configure.ac |  3 +++
> 2 files changed, 21 insertions(+), 8 deletions(-)

patch has been applied.

Regards

Marcel

