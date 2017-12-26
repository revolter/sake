import Foundation
import XCTest
import xcproj
import PathKit

@testable import SakeKit

final class GenerateProjectTests: XCTestCase {
    
    var pbxproj: PBXProj!
    var subject: GenerateProject!
    var written: [(String, Path)]!
    
    override func setUp() {
        super.setUp()
        written = []
        subject = GenerateProject(path: ".",
                                  write: { (project, _) in self.pbxproj = project.pbxproj },
                                  stringWrite: { self.written.append(($0, $1)) },
                                  filedescriptionLibraryPath: { Path("/libraries/description.dylib") },
                                  sakefilePath: { Path("Sakefile.swift") })
        try? subject.execute()
    }
    
    func test_project_writesTheCorrectMainSwift() {
        let expectedContent = """
import Foundation

// NOTE: Don't add anything to this file
// There should be a top level variable named sake in your Sakefile.swift
_ = sake
"""
        XCTAssertEqual(written.first?.0, expectedContent)
        XCTAssertEqual(written.first?.1.lastComponent, "main.swift")
    }
    
    func test_project_hasTheCorrectFileReferences() {
        XCTAssertTrue(pbxproj.objects.fileReferences.values.contains(PBXFileReference(reference: "FILE_REF_PRODUCT",
                                                                        sourceTree: .buildProductsDir,
                                                                        explicitFileType: "compiled.mach-o.executable",
                                                                        path: "Sakefile",
                                                                        includeInIndex: 0)))
        XCTAssertTrue(pbxproj.objects.fileReferences.values.contains(PBXFileReference(reference: "FILE_REF_SAKEFILE",
                                                                                      sourceTree: .absolute,
                                                                                      name: "Sakefile.swift",
                                                                                      lastKnownFileType: "sourcecode.swift",
                                                                                      path: "Sakefile.swift")))
        XCTAssertTrue(pbxproj.objects.fileReferences.values.contains(PBXFileReference(reference: "FILE_REF_MAIN",
                                                                                      sourceTree: .absolute,
                                                                                      name: "main.swift",
                                                                                      lastKnownFileType: "sourcecode.swift",
                                                                                      path: written.first?.1.absolute().string ?? "")))
        XCTAssertTrue(pbxproj.objects.fileReferences.values.contains(PBXFileReference(reference: "FILE_REF_LIB",
                                                                                      sourceTree: .absolute,
                                                                                      name: "description.dylib",
                                                                                      lastKnownFileType: "compiled.mach-o.dylib",
                                                                                      path: "/libraries/description.dylib")))
    }
    
    func test_project_hasTheCorrectGroups() {
        XCTAssertTrue(pbxproj.objects.groups.values.contains(PBXGroup(reference: "GROUP_PRODUCTS",
                                                               children: ["FILE_REF_PRODUCT"],
                                                               sourceTree: .group,
                                                               name: "Products")))
        XCTAssertTrue(pbxproj.objects.groups.values.contains(PBXGroup(reference: "GROUP_MAIN",
                                                                      children: ["FILE_REF_SAKEFILE", "GROUP_PRODUCTS", "GROUP_FRAMEWORKS"],
                                                                      sourceTree: .group)))
        XCTAssertTrue(pbxproj.objects.groups.values.contains(PBXGroup(reference: "GROUP_FRAMEWORKS",
                                                                                                    children: ["FILE_REF_LIB", "FILE_REF_LIB_UTILS"],
                                                                                                    sourceTree: .group,
                                                                                                    name: "Frameworks")))
    }
    
    func test_project_hasTheCorrectBuildFiles() {
        XCTAssertTrue(pbxproj.objects.buildFiles.values.contains(PBXBuildFile(reference: "BUILD_FILE_SAKEFILE",
                                                                              fileRef: "FILE_REF_SAKEFILE")))
        XCTAssertTrue(pbxproj.objects.buildFiles.values.contains(PBXBuildFile(reference: "BUILD_FILE_LIB",
                                                                              fileRef: "FILE_REF_LIB")))
    }
 
    func test_project_hasTheCorrectBuildPhases() {
        XCTAssertTrue(pbxproj.objects.buildPhases.values.contains(PBXFrameworksBuildPhase(reference: "FRAMEWORKS_BUILD_PHASE",
                                                                                          files: ["BUILD_FILE_LIB"],
                                                                                          buildActionMask: PBXFrameworksBuildPhase.defaultBuildActionMask,
                                                                                          runOnlyForDeploymentPostprocessing: 0)))
        XCTAssertTrue(pbxproj.objects.buildPhases.values.contains(PBXSourcesBuildPhase(reference: "SOURCE_BUILD_PHASE",
                                                                                       files: ["BUILD_FILE_SAKEFILE", "BUILD_FILE_MAIN"],
                                                                                       buildActionMask: PBXSourcesBuildPhase.defaultBuildActionMask,
                                                                                       runOnlyForDeploymentPostprocessing: 0)))
        XCTAssertTrue(pbxproj.objects.buildPhases.values.contains(PBXCopyFilesBuildPhase(reference: "COPY_FILES_BUILD_PHASE",
                                                                                         dstPath: "/usr/share/man/man1/",
                                                                                         dstSubfolderSpec: PBXCopyFilesBuildPhase.SubFolder.absolutePath,
                                                                                         buildActionMask: PBXCopyFilesBuildPhase.defaultBuildActionMask,
                                                                                         files: [],
                                                                                         runOnlyForDeploymentPostprocessing: 1)))
    }
    
    func test_project_hasTheCorrectConfigurations() {
        XCTAssertTrue(pbxproj.objects.buildConfigurations.values.contains(XCBuildConfiguration(reference: "CONFIGURATION_TARGET",
                                                                                                   name: "Debug",
                                                                                                   baseConfigurationReference: nil,
                                                                                                   buildSettings: [
                                                                                                    "LIBRARY_SEARCH_PATHS": "/libraries",
                                                                                                    "PRODUCT_NAME": "$(TARGET_NAME)",
                                                                                                    "SWIFT_INCLUDE_PATHS": "/libraries",
                                                                                                    "LD_RUNPATH_SEARCH_PATHS": "$(TOOLCHAIN_DIR)/usr/lib/swift/macosx @executable_path",
                                                                                                    "SWIFT_FORCE_DYNAMIC_LINK_STDLIB": true,
                                                                                                    "SWIFT_FORCE_STATIC_LINK_STDLIB": false,
                                                                                                    "SWIFT_VERSION": "4.0"])))
        XCTAssertTrue(pbxproj.objects.buildConfigurations.values.contains(XCBuildConfiguration(reference: "CONFIGURATION_PROJECT",
                                                                                               name: "Debug",
                                                                                               baseConfigurationReference: nil,
                                                                                               buildSettings: [
                                                                                                "ALWAYS_SEARCH_USER_PATHS": "NO",
                                                                                                "CLANG_ANALYZER_NONNULL": "YES",
                                                                                                "CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION": "YES_AGGRESSIVE",
                                                                                                "CLANG_CXX_LANGUAGE_STANDARD": "gnu++14",
                                                                                                "CLANG_CXX_LIBRARY": "libc++",
                                                                                                "CLANG_ENABLE_MODULES": "YES",
                                                                                                "CLANG_ENABLE_OBJC_ARC": "YES",
                                                                                                "CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING": "YES",
                                                                                                "CLANG_WARN_BOOL_CONVERSION": "YES",
                                                                                                "CLANG_WARN_COMMA": "YES",
                                                                                                "CLANG_WARN_CONSTANT_CONVERSION": "YES",
                                                                                                "CLANG_WARN_DIRECT_OBJC_ISA_USAGE": "YES_ERROR",
                                                                                                "CLANG_WARN_DOCUMENTATION_COMMENTS": "YES",
                                                                                                "CLANG_WARN_EMPTY_BODY": "YES",
                                                                                                "CLANG_WARN_ENUM_CONVERSION": "YES",
                                                                                                "CLANG_WARN_INFINITE_RECURSION": "YES",
                                                                                                "CLANG_WARN_INT_CONVERSION": "YES",
                                                                                                "CLANG_WARN_NON_LITERAL_NULL_CONVERSION": "YES",
                                                                                                "CLANG_WARN_OBJC_LITERAL_CONVERSION": "YES",
                                                                                                "CLANG_WARN_OBJC_ROOT_CLASS": "YES_ERROR",
                                                                                                "CLANG_WARN_RANGE_LOOP_ANALYSIS": "YES",
                                                                                                "CLANG_WARN_STRICT_PROTOTYPES": "YES",
                                                                                                "CLANG_WARN_SUSPICIOUS_MOVE": "YES",
                                                                                                "CLANG_WARN_UNGUARDED_AVAILABILITY": "YES_AGGRESSIVE",
                                                                                                "CLANG_WARN_UNREACHABLE_CODE": "YES",
                                                                                                "CLANG_WARN__DUPLICATE_METHOD_MATCH": "YES",
                                                                                                "COPY_PHASE_STRIP": "NO",
                                                                                                "DEBUG_INFORMATION_FORMAT": "dwarf",
                                                                                                "ENABLE_STRICT_OBJC_MSGSEND": "YES",
                                                                                                "ENABLE_TESTABILITY": "YES",
                                                                                                "GCC_C_LANGUAGE_STANDARD": "gnu11",
                                                                                                "GCC_DYNAMIC_NO_PIC": "NO",
                                                                                                "GCC_NO_COMMON_BLOCKS": "YES",
                                                                                                "GCC_OPTIMIZATION_LEVEL": "0",
                                                                                                "GCC_PREPROCESSOR_DEFINITIONS": "DEBUG=1 $(inherited)",
                                                                                                "GCC_WARN_64_TO_32_BIT_CONVERSION": "YES",
                                                                                                "GCC_WARN_ABOUT_RETURN_TYPE": "YES_ERROR",
                                                                                                "GCC_WARN_UNDECLARED_SELECTOR": "YES",
                                                                                                "GCC_WARN_UNINITIALIZED_AUTOS": "YES_AGGRESSIVE",
                                                                                                "GCC_WARN_UNUSED_FUNCTION": "YES",
                                                                                                "GCC_WARN_UNUSED_VARIABLE": "YES",
                                                                                                "LD_DYLIB_INSTALL_NAME": "@rpath",
                                                                                                "MACOSX_DEPLOYMENT_TARGET": "10.10",
                                                                                                "MTL_ENABLE_DEBUG_INFO": "YES",
                                                                                                "ONLY_ACTIVE_ARCH": "YES",
                                                                                                "SDKROOT": "macosx",
                                                                                                "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
                                                                                                "USE_HEADERMAP": "NO"])))
        XCTAssertTrue(pbxproj.objects.configurationLists.values.contains(XCConfigurationList(reference: "CONFIGURATION_LIST_PROJECT",
                                                                                              buildConfigurations: ["CONFIGURATION_PROJECT"],
                                                                                              defaultConfigurationName: "Debug",
                                                                                              defaultConfigurationIsVisible: 0)))
        XCTAssertTrue(pbxproj.objects.configurationLists.values.contains(XCConfigurationList(reference: "CONFIGURATION_LIST_TARGET",
                                                                                             buildConfigurations: ["CONFIGURATION_TARGET"],
                                                                                             defaultConfigurationName: "Debug",
                                                                                             defaultConfigurationIsVisible: 0)))
    }
    
    func test_project_hasTheCorrectTargets() {
        XCTAssertTrue(pbxproj.objects.nativeTargets.values.contains(PBXNativeTarget(reference: "NATIVE_TARGET",
                                                                                    name: "Sakefile",
                                                                                    buildConfigurationList: "CONFIGURATION_LIST_TARGET",
                                                                                    buildPhases: ["SOURCE_BUILD_PHASE", "FRAMEWORKS_BUILD_PHASE", "COPY_FILES_BUILD_PHASE"],
                                                                                    buildRules: [],
                                                                                    dependencies: [],
                                                                                    productName: "Sakefile",
                                                                                    productReference: "FILE_REF_PRODUCT",
                                                                                    productType: .commandLineTool)))
    }
    
    func test_project_hasTheCorrectProject() {
        XCTAssertTrue(pbxproj.objects.projects.values.contains(PBXProject(name: "Sakefile",
                                                                          reference: "PROJECT",
                                                                          buildConfigurationList: "CONFIGURATION_LIST_PROJECT",
                                                                          compatibilityVersion: "Xcode 8.0",
                                                                          mainGroup: "GROUP_MAIN",
                                                                          developmentRegion: "en",
                                                                          hasScannedForEncodings: 0,
                                                                          knownRegions: ["en"],
                                                                          productRefGroup: "GROUP_PRODUCTS",
                                                                          projectDirPath: "",
                                                                          projectReferences: [],
                                                                          projectRoot: "",
                                                                          targets: ["NATIVE_TARGET"],
                                                                          attributes: ["ORGANIZATIONNAME": "com.sake"])))
    }
    
}
