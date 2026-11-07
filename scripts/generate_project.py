"""Generate a dependency-free Xcode project; rerun after adding Swift files."""
from pathlib import Path
import hashlib
import plistlib

ROOT = Path(__file__).resolve().parents[1]
def uid(value): return hashlib.sha1(value.encode()).hexdigest()[:24].upper()
def q(value): return '"' + str(value).replace('\\', '\\\\').replace('"', '\\"') + '"'
objects = {}
def add(key, body):
    identity = uid(key)
    objects[identity] = '{ ' + body + ' };'
    return identity
def array(values): return '(' + ', '.join(values) + ',)' if values else '()'
def settings(values): return '{ ' + ' '.join(f'{k} = {q(v)};' for k, v in values.items()) + ' }'
def configs(key, base):
    refs = []
    for mode in ['Debug', 'Release']:
        values = dict(base)
        values['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone' if mode == 'Debug' else '-O'
        if mode == 'Debug': values['ENABLE_TESTABILITY'] = 'YES'
        refs.append(add(key + mode, f'isa = XCBuildConfiguration; name = {mode}; buildSettings = {settings(values)};'))
    return add(key + 'configs', f'isa = XCConfigurationList; buildConfigurations = {array(refs)}; defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;')

targets, products, files = [], [], []
app_id = uid('targetBSCKU')
for name, folders, product_type, extension in [
    ('BSCKU', ['App', 'Core', 'Features', 'Web', 'Services'], 'application', 'app'),
    ('BSCKUTests', ['Tests', 'WebTests'], 'bundle.unit-test', 'xctest'),
    ('BSCKUUITests', ['UITests'], 'bundle.ui-testing', 'xctest')]:
    builds = []
    for folder in folders:
        for path in sorted((ROOT / folder).rglob('*.swift')):
            rel = path.relative_to(ROOT).as_posix()
            ref = add('file' + rel, f'isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {q(rel)}; sourceTree = "<group>";')
            files.append(ref)
            builds.append(add('build' + rel, f'isa = PBXBuildFile; fileRef = {ref};'))
    source = add(name + 'sources', f'isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = {array(builds)}; runOnlyForDeploymentPostprocessing = 0;')
    resource_builds = []
    if name == 'BSCKU':
        for rel in ['App/PrivacyInfo.xcprivacy', 'App/Assets.xcassets']:
            file_type = 'folder.assetcatalog' if rel.endswith('.xcassets') else 'text.xml'
            ref = add('file' + rel, f'isa = PBXFileReference; lastKnownFileType = {file_type}; path = {q(rel)}; sourceTree = "<group>";')
            files.append(ref)
            resource_builds.append(add('build' + rel, f'isa = PBXBuildFile; fileRef = {ref};'))
        translations = []
        for language in ['ar', 'en']:
            rel = f'Localization/{language}.lproj/InfoPlist.strings'
            translations.append(add('file' + rel, f'isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = {language}; path = {q(rel)}; sourceTree = "<group>";'))
        variant = add('InfoPlistTranslations', f'isa = PBXVariantGroup; children = {array(translations)}; name = InfoPlist.strings; sourceTree = "<group>";')
        files.append(variant)
        resource_builds.append(add('buildInfoPlistTranslations', f'isa = PBXBuildFile; fileRef = {variant};'))
    resources = add(name + 'resources', f'isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = {array(resource_builds)}; runOnlyForDeploymentPostprocessing = 0;')
    product = add(name + 'product', f'isa = PBXFileReference; explicitFileType = {q("wrapper.application" if extension == "app" else "wrapper.cfbundle")}; path = {q(name + "." + extension)}; sourceTree = BUILT_PRODUCTS_DIR;')
    products.append(product)
    base = {'PRODUCT_NAME': '$(TARGET_NAME)', 'PRODUCT_BUNDLE_IDENTIFIER': 'com.biosciku.' + name.lower(), 'SWIFT_VERSION': '6.0', 'IPHONEOS_DEPLOYMENT_TARGET': '17.0', 'SDKROOT': 'iphoneos', 'SUPPORTED_PLATFORMS': 'iphoneos iphonesimulator', 'TARGETED_DEVICE_FAMILY': '1,2', 'CODE_SIGN_STYLE': 'Automatic', 'GENERATE_INFOPLIST_FILE': 'YES', 'SWIFT_STRICT_CONCURRENCY': 'complete'}
    deps = []
    if name == 'BSCKU':
        base.update({'GENERATE_INFOPLIST_FILE': 'NO', 'INFOPLIST_FILE': 'App/Info.plist', 'CURRENT_PROJECT_VERSION': '1', 'MARKETING_VERSION': '1.0.0'})
    else:
        proxy = add(name + 'proxy', f'isa = PBXContainerItemProxy; containerPortal = {uid("project")}; proxyType = 1; remoteGlobalIDString = {app_id}; remoteInfo = BSCKU;')
        deps.append(add(name + 'dependency', f'isa = PBXTargetDependency; target = {app_id}; targetProxy = {proxy};'))
        if name == 'BSCKUTests': base.update({'TEST_HOST': '$(BUILT_PRODUCTS_DIR)/BSCKU.app/BSCKU', 'BUNDLE_LOADER': '$(TEST_HOST)'})
        else: base['TEST_TARGET_NAME'] = 'BSCKU'
    conf = configs(name, base)
    targets.append(add('target' + name, f'isa = PBXNativeTarget; buildConfigurationList = {conf}; buildPhases = {array([source, resources])}; buildRules = (); dependencies = {array(deps)}; name = {name}; productName = {name}; productReference = {product}; productType = {q("com.apple.product-type." + product_type)};'))
products_group = add('products', f'isa = PBXGroup; children = {array(products)}; name = Products; sourceTree = "<group>";')
root_group = add('root', f'isa = PBXGroup; children = {array(files + [products_group])}; sourceTree = "<group>";')
project_configs = configs('project', {'CLANG_ENABLE_MODULES': 'YES', 'SWIFT_VERSION': '6.0', 'IPHONEOS_DEPLOYMENT_TARGET': '17.0'})
project = add('project', f'isa = PBXProject; attributes = {{ LastUpgradeCheck = 1600; BuildIndependentTargetsInParallel = YES; }}; buildConfigurationList = {project_configs}; compatibilityVersion = "Xcode 14.0"; developmentRegion = ar; hasScannedForEncodings = 0; knownRegions = (ar, en, Base); mainGroup = {root_group}; productRefGroup = {products_group}; projectDirPath = ""; projectRoot = ""; targets = {array(targets)};')
dest = ROOT / 'BSCKU.xcodeproj'
dest.mkdir(exist_ok=True)
(dest / 'project.pbxproj').write_text('// !$*UTF8*$!\n{ archiveVersion = 1; classes = {}; objectVersion = 56; objects = {\n' + '\n'.join(f'{k} = {v}' for k,v in objects.items()) + f'\n}}; rootObject = {project}; }}\n', encoding='utf-8')
scheme_dir = dest / 'xcshareddata/xcschemes'
scheme_dir.mkdir(parents=True, exist_ok=True)
def ref(name): return f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{uid("target"+name)}" BuildableName="{name}.{ "app" if name == "BSCKU" else "xctest"}" BlueprintName="{name}" ReferencedContainer="container:BSCKU.xcodeproj"/>'
(scheme_dir / 'BSCKU.xcscheme').write_text(f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1600" version="1.3">
<BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{ref('BSCKU')}</BuildActionEntry></BuildActionEntries></BuildAction>
<TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables><TestableReference skipped="NO">{ref('BSCKUTests')}</TestableReference><TestableReference skipped="NO">{ref('BSCKUUITests')}</TestableReference></Testables></TestAction>
<LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">{ref('BSCKU')}</BuildableProductRunnable></LaunchAction>
<ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{ref('BSCKU')}</BuildableProductRunnable></ProfileAction>
<AnalyzeAction buildConfiguration="Debug"/><ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>''', encoding='utf-8')
print(f'Generated {dest.name}: {len(files)} source/resource references, 3 targets')
