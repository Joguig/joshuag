job {
	name "web-vinyl-ruby"
	using "TEMPLATE-autobuild"
	scm {
		git {
			remote {
				github 'web/vinyl-ruby', 'ssh', 'git-aws.internal.justin.tv'
				credentials 'git-aws-read-key'
			}
			clean true
		}
	}
	steps {
		shell 'manta -v -f build.json'
	}
}
