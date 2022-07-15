import docker


def GetPerfGcc(benchmark, flags, papi=False):
    # Deal with flags list
    fmtd_flags = ""
    for flag in flags:
        fmtd_flags += "," + flag
    
    fmtd_flags = fmtd_flags[1:] if ( len(fmtd_flags) != 0 and fmtd_flags[0] == ',' ) \
                    else fmtd_flags
    
    # Connect to a docker daemon.
    client=docker.from_env()

    # Run containers
    sCmd = f"compile.sh -b {benchmark} -p '{fmtd_flags}'"
    if papi == True:
        sCmd = sCmd + " --papi"

    bRes = client.containers.run("confsys/gcc_benchmark:v1", sCmd, privileged=True)
    print(bRes.decode('utf-8').strip())

if __name__== "__main__":
    GetPerfGcc("gemm", [], papi=True)
    GetPerfGcc("gemm", ["fno-cse-follow-jumps","fno-rerun-cse-after-loop","fno-ipa-cp"], papi=True)