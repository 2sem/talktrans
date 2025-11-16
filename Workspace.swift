import ProjectDescription

fileprivate let projects: [Path] = ["App", "ThirdParty", "DynamicThirdParty"]
    .map{ "Projects/\($0)" }

let workspace = Workspace(name: "talktrans", projects: projects)