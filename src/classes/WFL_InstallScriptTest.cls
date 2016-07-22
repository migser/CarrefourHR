@isTest
public class WFL_InstallScriptTest {

    @isTest(SeeAllData=true)
    static void testInstallScript() {
        WFL_InstallScript installScript = new WFL_InstallScript();
        Test.testInstall(installScript, null);
    }
}