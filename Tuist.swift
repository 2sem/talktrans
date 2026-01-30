import ProjectDescription

let tuist = Tuist(
    fullHandle: "gamehelper/talktrans",
    project: .tuist(
        compatibleXcodeVersions: .upToNextMajor("26.0"),
//                    swiftVersion: "",
//                    plugins: <#T##[PluginLocation]#>,
        generationOptions: .options(
            enableCaching: true
        ),
//                    installOptions: <#T##Tuist.InstallOptions#>)
    )
)
