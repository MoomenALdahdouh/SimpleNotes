#!/usr/bin/env python3
"""Generate SimpleNotes.xcodeproj/project.pbxproj."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def nid(n: int) -> str:
    return f"{n:024X}"


CORE_SOURCES = [
    "SimpleNotesCore/FileFormat.swift",
    "SimpleNotesCore/FilenameGenerator.swift",
    "SimpleNotesCore/FileNameSanitizer.swift",
    "SimpleNotesCore/WordCounter.swift",
    "SimpleNotesCore/FileService.swift",
]

APP_SOURCES = [
    "SimpleNotes/App/SimpleNotesApp.swift",
    "SimpleNotes/App/AppDelegate.swift",
    "SimpleNotes/App/AppCommands.swift",
    "SimpleNotes/App/DocumentSession.swift",
    "SimpleNotes/App/FontSizes.swift",
    "SimpleNotes/Views/ContentView.swift",
    "SimpleNotes/Views/StatusBarView.swift",
    "SimpleNotes/Views/AboutView.swift",
    "SimpleNotes/Editor/NotesEditor.swift",
    "SimpleNotes/Editor/NotesNSTextView.swift",
    "SimpleNotes/Services/Alerts.swift",
    "SimpleNotes/Services/FileWatcher.swift",
]

TEST_SOURCES = [
    "SimpleNotesTests/FilenameGeneratorTests.swift",
    "SimpleNotesTests/FileNameSanitizerTests.swift",
    "SimpleNotesTests/WordCounterTests.swift",
    "SimpleNotesTests/FileServiceTests.swift",
    "SimpleNotesTests/EncodingTests.swift",
    "SimpleNotesTests/UndoRedoTests.swift",
]


def main() -> None:
    i = 1

    def next_id() -> str:
        nonlocal i
        value = nid(i)
        i += 1
        return value

    project = next_id()
    core_target = next_id()
    app_target = next_id()
    test_target = next_id()
    core_product = next_id()
    app_product = next_id()
    test_product = next_id()
    main_group = next_id()
    products_group = next_id()
    core_group = next_id()
    app_group = next_id()
    app_app_group = next_id()
    app_views_group = next_id()
    app_editor_group = next_id()
    app_services_group = next_id()
    app_resources_group = next_id()
    tests_group = next_id()
    core_sources_phase = next_id()
    app_sources_phase = next_id()
    test_sources_phase = next_id()
    app_resources_phase = next_id()
    app_frameworks_phase = next_id()
    test_frameworks_phase = next_id()
    project_configs = next_id()
    core_configs = next_id()
    app_configs = next_id()
    test_configs = next_id()
    project_debug = next_id()
    project_release = next_id()
    core_debug = next_id()
    core_release = next_id()
    app_debug = next_id()
    app_release = next_id()
    test_debug = next_id()
    test_release = next_id()
    core_link = next_id()
    core_test_link = next_id()
    icon_file = next_id()
    icon_build = next_id()
    plist_file = next_id()
    entitlements_file = next_id()

    file_ids = {}
    build_ids = {}
    for path in CORE_SOURCES + APP_SOURCES + TEST_SOURCES:
        file_ids[path] = next_id()
        build_ids[path] = next_id()

    objects: list[str] = []

    def add(oid: str, body: str) -> None:
        objects.append(f"\t\t{oid} = {body};\n")

    for path in CORE_SOURCES + APP_SOURCES + TEST_SOURCES:
        name = Path(path).name
        add(
            file_ids[path],
            f"{{\n\t\t\tisa = PBXFileReference;\n\t\t\tlastKnownFileType = sourcecode.swift;\n\t\t\tpath = {name};\n\t\t\tsourceTree = \"<group>\";\n\t\t}}",
        )
        add(
            build_ids[path],
            f"{{\n\t\t\tisa = PBXBuildFile;\n\t\t\tfileRef = {file_ids[path]} /* {name} */;\n\t\t}}",
        )

    add(
        icon_file,
        "{\n\t\t\tisa = PBXFileReference;\n\t\t\tlastKnownFileType = image.icns;\n\t\t\tpath = AppIcon.icns;\n\t\t\tsourceTree = \"<group>\";\n\t\t}",
    )
    add(
        icon_build,
        f"{{\n\t\t\tisa = PBXBuildFile;\n\t\t\tfileRef = {icon_file} /* AppIcon.icns */;\n\t\t}}",
    )
    add(
        plist_file,
        "{\n\t\t\tisa = PBXFileReference;\n\t\t\tlastKnownFileType = text.plist.xml;\n\t\t\tpath = Info.plist;\n\t\t\tsourceTree = \"<group>\";\n\t\t}",
    )
    add(
        entitlements_file,
        "{\n\t\t\tisa = PBXFileReference;\n\t\t\tlastKnownFileType = text.plist.entitlements;\n\t\t\tpath = SimpleNotes.entitlements;\n\t\t\tsourceTree = \"<group>\";\n\t\t}",
    )
    add(
        core_product,
        "{\n\t\t\tisa = PBXFileReference;\n\t\t\texplicitFileType = archive.ar;\n\t\t\tincludeInIndex = 0;\n\t\t\tpath = libSimpleNotesCore.a;\n\t\t\tsourceTree = BUILT_PRODUCTS_DIR;\n\t\t}",
    )
    add(
        app_product,
        "{\n\t\t\tisa = PBXFileReference;\n\t\t\texplicitFileType = wrapper.application;\n\t\t\tincludeInIndex = 0;\n\t\t\tpath = \"Simple Notes.app\";\n\t\t\tsourceTree = BUILT_PRODUCTS_DIR;\n\t\t}",
    )
    add(
        test_product,
        "{\n\t\t\tisa = PBXFileReference;\n\t\t\texplicitFileType = wrapper.cfbundle;\n\t\t\tincludeInIndex = 0;\n\t\t\tpath = SimpleNotesTests.xctest;\n\t\t\tsourceTree = BUILT_PRODUCTS_DIR;\n\t\t}",
    )
    add(
        core_link,
        f"{{\n\t\t\tisa = PBXBuildFile;\n\t\t\tfileRef = {core_product} /* libSimpleNotesCore.a */;\n\t\t}}",
    )
    add(
        core_test_link,
        f"{{\n\t\t\tisa = PBXBuildFile;\n\t\t\tfileRef = {core_product} /* libSimpleNotesCore.a */;\n\t\t}}",
    )

    def group(oid: str, name: str, path: str | None, children: list[str]) -> None:
        kids = "".join(f"\n\t\t\t\t{child},\n" for child in children)
        path_line = f"\n\t\t\tpath = {path};" if path else ""
        add(
            oid,
            f"{{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = ({kids}\t\t\t);{path_line}\n\t\t\tname = {name};\n\t\t\tsourceTree = \"<group>\";\n\t\t}}",
        )

    group(core_group, "SimpleNotesCore", "SimpleNotesCore", [file_ids[p] for p in CORE_SOURCES])
    group(app_app_group, "App", "App", [file_ids[p] for p in APP_SOURCES if "/App/" in p])
    group(app_views_group, "Views", "Views", [file_ids[p] for p in APP_SOURCES if "/Views/" in p])
    group(app_editor_group, "Editor", "Editor", [file_ids[p] for p in APP_SOURCES if "/Editor/" in p])
    group(app_services_group, "Services", "Services", [file_ids[p] for p in APP_SOURCES if "/Services/" in p])
    group(app_resources_group, "Resources", "Resources", [icon_file, plist_file, entitlements_file])
    group(
        app_group,
        "SimpleNotes",
        "SimpleNotes",
        [app_app_group, app_views_group, app_editor_group, app_services_group, app_resources_group],
    )
    group(tests_group, "SimpleNotesTests", "SimpleNotesTests", [file_ids[p] for p in TEST_SOURCES])
    group(products_group, "Products", None, [core_product, app_product, test_product])
    group(main_group, "SimpleNotes", None, [core_group, app_group, tests_group, products_group])

    def sources_phase(oid: str, name: str, paths: list[str]) -> None:
        files = "".join(f"\n\t\t\t\t{build_ids[p]} /* {Path(p).name} in Sources */,\n" for p in paths)
        add(
            oid,
            f"{{\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = ({files}\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}}",
        )

    sources_phase(core_sources_phase, "Sources", CORE_SOURCES)
    sources_phase(app_sources_phase, "Sources", APP_SOURCES)
    sources_phase(test_sources_phase, "Sources", TEST_SOURCES)

    add(
        app_resources_phase,
        f"{{\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t\t{icon_build} /* AppIcon.icns in Resources */,\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}}",
    )
    add(
        app_frameworks_phase,
        f"{{\n\t\t\tisa = PBXFrameworksBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t\t{core_link} /* libSimpleNotesCore.a in Frameworks */,\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}}",
    )
    add(
        test_frameworks_phase,
        f"{{\n\t\t\tisa = PBXFrameworksBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t\t{core_test_link} /* libSimpleNotesCore.a in Frameworks */,\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}}",
    )

    add(
        core_target,
        f"""{{
			isa = PBXNativeTarget;
			buildConfigurationList = {core_configs};
			buildPhases = (
				{core_sources_phase},
			);
			buildRules = (
			);
			dependencies = (
			);
			name = SimpleNotesCore;
			productName = SimpleNotesCore;
			productReference = {core_product};
			productType = "com.apple.product-type.library.static";
		}}""",
    )
    add(
        app_target,
        f"""{{
			isa = PBXNativeTarget;
			buildConfigurationList = {app_configs};
			buildPhases = (
				{app_sources_phase},
				{app_frameworks_phase},
				{app_resources_phase},
			);
			buildRules = (
			);
			dependencies = (
			);
			name = "Simple Notes";
			productName = SimpleNotes;
			productReference = {app_product};
			productType = "com.apple.product-type.application";
		}}""",
    )
    add(
        test_target,
        f"""{{
			isa = PBXNativeTarget;
			buildConfigurationList = {test_configs};
			buildPhases = (
				{test_sources_phase},
				{test_frameworks_phase},
			);
			buildRules = (
			);
			dependencies = (
			);
			name = SimpleNotesTests;
			productName = SimpleNotesTests;
			productReference = {test_product};
			productType = "com.apple.product-type.bundle.unit-test";
		}}""",
    )
    add(
        project,
        f"""{{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1600;
				LastUpgradeCheck = 1600;
			}};
			buildConfigurationList = {project_configs};
			compatibilityVersion = "Xcode 15.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = {main_group};
			productRefGroup = {products_group};
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{core_target},
				{app_target},
				{test_target},
			);
		}}""",
    )

    common_project = """
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				SDKROOT = macosx;
				SWIFT_VERSION = 5.0;
"""
    add(
        project_debug,
        "{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {"
        + common_project
        + """
				DEBUG_INFORMATION_FORMAT = dwarf;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		}""",
    )
    add(
        project_release,
        "{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {"
        + common_project
        + """
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
			};
			name = Release;
		}""",
    )

    def config_list(oid: str, debug_id: str, release_id: str) -> None:
        add(
            oid,
            f"""{{
			isa = XCConfigurationList;
			buildConfigurations = (
				{debug_id},
				{release_id},
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}}""",
        )

    add(
        core_debug,
        """{
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGNING_ALLOWED = NO;
				EXECUTABLE_PREFIX = lib;
				PRODUCT_MODULE_NAME = SimpleNotesCore;
				PRODUCT_NAME = SimpleNotesCore;
				SKIP_INSTALL = YES;
				SWIFT_INSTALL_OBJC_HEADER = NO;
			};
			name = Debug;
		}""",
    )
    add(
        core_release,
        """{
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGNING_ALLOWED = NO;
				EXECUTABLE_PREFIX = lib;
				PRODUCT_MODULE_NAME = SimpleNotesCore;
				PRODUCT_NAME = SimpleNotesCore;
				SKIP_INSTALL = YES;
				SWIFT_INSTALL_OBJC_HEADER = NO;
			};
			name = Release;
		}""",
    )
    app_settings = """
				ASSETCATALOG_COMPILER_APPICON_NAME = "";
				CODE_SIGN_ENTITLEMENTS = SimpleNotes/Resources/SimpleNotes.entitlements;
				CODE_SIGN_IDENTITY = "-";
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				ENABLE_HARDENED_RUNTIME = NO;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = SimpleNotes/Resources/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.simplenotes.SimpleNotes;
				PRODUCT_NAME = SimpleNotes;
			"""
    add(
        app_debug,
        "{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {"
        + app_settings
        + "\n\t\t\t};\n\t\t\tname = Debug;\n\t\t}",
    )
    add(
        app_release,
        "{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {"
        + app_settings
        + "\n\t\t\t};\n\t\t\tname = Release;\n\t\t}",
    )
    test_settings = """
				CODE_SIGNING_ALLOWED = NO;
				GENERATE_INFOPLIST_FILE = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.simplenotes.SimpleNotesTests;
				PRODUCT_NAME = SimpleNotesTests;
				SWIFT_EMIT_LOC_STRINGS = NO;
			"""
    add(
        test_debug,
        "{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {"
        + test_settings
        + "\n\t\t\t};\n\t\t\tname = Debug;\n\t\t}",
    )
    add(
        test_release,
        "{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {"
        + test_settings
        + "\n\t\t\t};\n\t\t\tname = Release;\n\t\t}",
    )

    config_list(project_configs, project_debug, project_release)
    config_list(core_configs, core_debug, core_release)
    config_list(app_configs, app_debug, app_release)
    config_list(test_configs, test_debug, test_release)

    pbx = (
        "// !$*UTF8*$!\n{\n\tarchiveVersion = 1;\n\tclasses = {\n\t};\n\tobjectVersion = 56;\n\tobjects = {\n"
        + "".join(objects)
        + f"\t}};\n\trootObject = {project} /* Project object */;\n}}\n"
    )

    dest = ROOT / "SimpleNotes.xcodeproj" / "project.pbxproj"
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(pbx)
    scheme_dir = ROOT / "SimpleNotes.xcodeproj" / "xcshareddata" / "xcschemes"
    scheme_dir.mkdir(parents=True, exist_ok=True)
    (scheme_dir / "Simple Notes.xcscheme").write_text(
        f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1600" version="1.7">
   <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES">
      <BuildActionEntries>
         <BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">
            <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{app_target}" BuildableName="Simple Notes.app" BlueprintName="Simple Notes" ReferencedContainer="container:SimpleNotes.xcodeproj"/>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES">
      <Testables>
         <TestableReference skipped="NO">
            <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{test_target}" BuildableName="SimpleNotesTests.xctest" BlueprintName="SimpleNotesTests" ReferencedContainer="container:SimpleNotes.xcodeproj"/>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{app_target}" BuildableName="Simple Notes.app" BlueprintName="Simple Notes" ReferencedContainer="container:SimpleNotes.xcodeproj"/>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{app_target}" BuildableName="Simple Notes.app" BlueprintName="Simple Notes" ReferencedContainer="container:SimpleNotes.xcodeproj"/>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction buildConfiguration="Debug"/>
   <ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>
"""
    )
    print(f"Wrote {dest}")


if __name__ == "__main__":
    main()
