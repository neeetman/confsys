import docker


def GetPerfClang(benchmark, passes, papi=False):
    # Deal with passes list
    polly_passes = ""
    stadard_passes = ""
    for ps in passes:
        if "polly" in ps:
            polly_passes += ',' + ps
        else:
            stadard_passes += ',' + ps
    
    RmPrefix = lambda s: s[1:] if ( len(s) != 0 and s[0] == ',' ) else s
    polly_passes = RmPrefix(polly_passes)
    stadard_passes = RmPrefix(stadard_passes)
    
    # Connect to a docker daemon.
    client=docker.from_env()

    # Run containers
    sCmd = f"compile.sh -b {benchmark} -sp '{stadard_passes}' -pp '{polly_passes}'"
    if papi == True:
        sCmd = sCmd + " --papi"

    bRes = client.containers.run("confsys/clang_benchmark:v1", sCmd, privileged=True)
    print(bRes.decode('utf-8').strip())

if __name__== "__main__":
    GetPerfClang("gemm", [], papi=True)
    GetPerfClang("gemm", ["polly-codegen","adce","polly-simplify"], papi=True)
