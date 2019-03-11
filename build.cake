#addin nuget:?package=Cake.Docker&version=0.9.7

using System.Runtime.InteropServices;
using System.Linq;
using System.IO;
using Path = System.IO.Path;
using System.Net.Sockets;

var target = Argument("target", "Setup");
var containerNameOracleDb = "oracle-db-container";
var imageNameOracleDb = "oracle-db-image";
var dockerUsername = Argument("dockerUsername", "");
var dockerPassword = Argument("dockerPassword", "");

Task("DockerLogin")
    .Description("Login to docker with Ticket CI credentials")
    .Does(() => {
        StartProcess("docker", new ProcessSettings
        {
            Arguments = $"login -u {dockerUsername} -p {dockerPassword}"
        });
    });

Task("FollowContainerLogs")
    .Description("Follow Oracle Db container logs.")
    .Does(() => {
        StartProcess("docker", new ProcessSettings { Arguments = $"logs {containerNameOracleDb} -f" });
    });

Task("CreateContainerImage")
    .Description("Creates Oracle dev image.")
    .Does(() => {
        StartProcess("docker", new ProcessSettings
        {
            Arguments = $"build -t {imageNameOracleDb} ." ,
            WorkingDirectory = "."
        });
    });

Task("RemoveContainer")
    .Description("Stop and Remove Oracle container.")
    .Does(() => StartProcess("docker", new ProcessSettings { Arguments = $"rm -f {containerNameOracleDb}" }))
    .Does(() => StartProcess("docker", new ProcessSettings { Arguments = $"volume prune -f"}));

Task("RunContainer")
    .Description("Runs a new container for Oracle Db.")
    .IsDependentOn("RemoveContainer")
    .Does(() => {
        var hostPath = System.IO.Path.Combine(System.IO.Directory.GetCurrentDirectory(), "volume");
        StartProcess("docker", new ProcessSettings { Arguments = $"run --name={containerNameOracleDb} -d -p 8081:8080 -p 22:22 -p 1521:1521 -v {hostPath}:/volume {imageNameOracleDb}" });
    });

Task("WaitContainerStartComplete")
    .Description("Waits for the Oracle Db container to finish starting.")
    .Does(() => {
        DockerExec(containerNameOracleDb, "bash", "-c", "\"while ! test -f /home/oracle/setup/.sqlinitdone && ! test -f /home/oracle/setup/.sqliniterror; do echo Waiting for Db start...; sleep 5; done\"");
    });

Task("SetupAndWaitContainer")
    .Description("Creates Oracle Db container image, runs its container and wait for it to finish.")
    .IsDependentOn("SetupImageAndContainer")
    .IsDependentOn("WaitContainerStartComplete");

Task("SetupContainer")
    .Description("Creates Oracle Db container image and runs its container.")
    .IsDependentOn("SetupImageAndContainer")
    .IsDependentOn("FollowContainerLogs");

Task("SetupImageAndContainer")
    .Description("Creates Oracle Db container image and runs its container.")
    .IsDependentOn("CreateContainerImage")
    .IsDependentOn("RunContainer");

RunTarget(target);
